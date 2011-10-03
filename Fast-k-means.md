We have covered a basic k-means implementation with `rmr` in the [[Tutorial]]. But if you tried it out you probably have noticed that its
performance leaves to be desired and wonder if anything can be done about it. Or your have read [[Efficient rmr techniques]] and would like to
see those suggestions put to work beyond the trivial "large sums" example used therein. Then this document should be of interest to you since we
will cover an implementation that is modestly more complex and is two orders of magnitude faster. To make the most of the following
explanation, it's recommended that you read the other two documents first.

First we need to reorganize our data representation a little, creating bulkier records that contain a small subset of the data set each, as
opposed to a single point. So instead of storing one point per record we will store a matrix, with on data point per row. We'll set the
number of rows to 1000 which is enough to reap the benefits of using "vectorised" functions in R but not big enough to create memory
problems. So this is how a sample call would look like, with the first argument being a sample dataset.

```r
recsize = 1000
kmeans(
  to.dfs(
    lapply(
	  1:100, 
      function(i) keyval(
	    NULL, 
        cbind(sample(0:2, recsize, replace = T) + 
		        rnorm(recsize, sd = .1), 
              sample(0:3, recsize, replace = T) + 
                rnorm(recsize, sd = .1))))), 
    12, iterations = 5, fast = T)
```

This creates and processes a dataset with 100,000 data points, organized in 100 records. For a larger data set you would need to increase
the number of records only, the size of each record can stay the same. As you may recall, the implementation of kmeans we described in the
tutorial was organized in two functions, one containing the main iteration loop and the other computing distances and new centers. The good
news is the first function can stay largely the same but for the addition of a flag that tells whether to use the optimized version of the
"inner" function, so we don't need to cover it here (the code is in the source under `tests`, only in the dev branch for now) and a
different default for the distance function &mdash; more on this soon. The important and quite radical changes are in the `kmeans.iter.fast`
function, which provides an alternative to the `kmeans.iter` function in the original implementation. Let's first discuss why we need a
different default distance function, and in general why the distance function has a different signature in the fast version. One
of the most CPU intensive tasks in this algorithm is computing distances between a candidate center and each data point. If we don't
implement this one in an efficient way, we can't hope for an overall efficient implementation. Since it takes about a microsecond to call
the simplest function in R, we need to get a significant amount of work done for each call. Therefore, instead of specifying the distance
function as a function of two points, we will switch to a function of one point and and a set thereof that returns that distance between the
first argument and each element of the second. In this implementation we will us a matrix instead of a set, since there are powerful
primitives available to operate on matrices. The following is the default distance function with this new signature, where we can see that
we avoided any explicit loops over the rows of the matrix `yy`. There are two implicit loops, `Reduce` and `lapply`, but internally they
used vectorized operators.

```r
    fast.dist = function(yy, x) { 
      squared.diffs = (t(t(yy) - x))^2
      sqrt(Reduce(`+`, lapply(1:dim(yy)[2], function(d) squared.diffs[,d])))} 
```

With fast distance computation taken care of, at least for the euclidean case, let's look at the fast implementation of the kmeans iteration.

```r
kmeans.iter.fast = 
function(points, distfun = fast.dist, ncenters = dim(centers)[1], centers = NULL) {
```

There are no news as far as the signature but for a different distance default, so we can move on to the body. The following function is a
conversion function that allows us to work around a limitation in the RJSONIO library we are using to serialize R objects. Unserializing a
deserialized matrix returns a list of vectors, which we can easily turn into a matrix again. Whenever you have doubts whether the R object
you intend to use as an argument or return value of a mapper or reducer will be encoded and decoded correctly, an option is to try
`RJSONIO::fromJSON(RJSONIO::toJSON(x))` where `x` is the object of interest. This a price to pay for using a language agnostic serialization
scheme.

```r
    list.to.matrix = function(l) do.call(rbind,l)
```

The next is the main mapreduce call, which, as in the Tutorial, can have two different map function: let's look at each in detal.
```r
    newCenters = from.dfs(
      mapreduce(
        input = points,
```

The first of the two map functions is used only for the first iteration, when no set of cluster centers is available, only a number, and
randomly assigns each point to a center, so nothing new w.r.t. the Tutorial, but here the argument `v` represents multiple data points and
we need to assign each of them to a center efficiently. Moreover, we are going to switch from computing the means of data points in a
cluster to computing their sums and  counts, dealaying taking the ratio of the two as much as possible. This way we can apply early data
reduction as will be clear soon. The first step in the mapper is devoted to that, that is extend the matrix of points with a column of
counts, all initialized to one. The next line assigns points to clusters using `sample`. This assignment is then supplied to the function `by`
which applies a column sum to each cluster-defined group of rows in the matrix `v` of data points. This is where we apply the `sum`
operation at the earliest possible stage &mdash; you can see it as a in-map combiner. Also, since the first column of the matrix is now
devoted to counts, we are updating those as well. In the last line, the only thing left is to generate a list of keyvalue pairs, one per
center, and return it.
```r
        map = 
          if (is.null(centers)) {
            function(k, v) {
              v = cbind(1, list.to.matrix(v))
              centers = sample(1:ncenters, dim(v)[[1]], replace = TRUE) 
              clusters = unclass(by(v,centers,function(x) apply(x,2,sum)))
              lapply(names(clusters), function(cl) keyval(as.integer(cl), clusters[[cl]]))}}
```

For all iterations after the first, the assignment of points to centers follows a min distance criterion. The first lines back-converts `v`
to a matrix whereas the second uses the aforementioned `fast.dist` function in combination with `apply` to generate a data points x centers
matrix of distances. The next assignment, which takes a few lines, aims to compute the row by row min of this distance matrix and return the
index of a column containing the minimum for each row. We can not use the customary function `min` to accomplish this as it returns only a
single number, so we would need to call it for each data point. So we need to use its parallel, less known version `pmin` and apply it to
the columns of the distance matrix. The output of this is a two column matrix where each row as the index of a row and the column index of
the index of the min for that row. The following assignment sorts this matrix so that the results are in the same order as the `v`
matrix. The last few steps are the same as for the first type of map.

```r
          else {
            function(k, v) {
              v = list.to.matrix(v)
              dist.mat = apply(centers, 1, function(x) fast.dist(v, x))
              closest.centers = as.data.frame(
                which(
                  dist.mat == do.call(
                    pmin,
                    lapply(1:dim(dist.mat)[2], 
                           function(i) dist.mat[,i])), 
                  arr.ind=TRUE))
              closest.centers[closest.centers$row,] = closest.centers
              v = cbind(1, v)
              clusters = unclass(by(v,closest.centers$col,function(x) apply(x,2,sum)))
              lapply(names(clusters), function(cl) keyval(as.integer(cl), clusters[[cl]]))}},
```

In the reduce function, we simply sum over the colums of the matrix of points associated with the same cluster center. Actually, since we
have started adding over sugroups of points in the mapper itself, what we are adding here are already partial sums and partial counts (in
the first column, you may rememeber, we store counts). Since this is an associative and commutative operation, it only helps to also switch
the combiner on.

```r
        reduce = function(k, vv) {
          keyval(NULL, apply(list.to.matrix(vv), 2, sum))},
        combine = T),
```

The last few lines are an optional argument to `from.dfs` that operates a conversion from list to dataframe when it is possible, the
selection of centers with at least a count of one associated point and, at the very last step, converting sums into averages.

```r
      todataframe = T)
  newCenters = newCenters[newCenters[,1] > 0,]
    (newCenters/newCenters[,1])[,-1]}
```
