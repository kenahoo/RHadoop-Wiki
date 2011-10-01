We have covered a basic k-means implementation with `rmr` in the [[Tutorial]]. But if you tried it out you probably have noticed that its
performance leaves to be desired and wonder if anything can be done about it. Or your have read [[Efficient rmr techniques]] and would like to
see those suggestions put to work beyond the trivial "large sums" example used therein. Then this page should be of interest to you since we
will cover an implementation that is modestly more complex and is two orders of magnitude faster. To make the most of the following
explanation, it's recommended that you read the other two documents first.

First we need to reorganize our data representation a little, creating bulkier records that contain a small subset of the data set, but more
than a single point. So instead of storing one point per record we will store a matrix thereof per record, with on data point per row. We'll
set the number of rows to 1000 which is enough to reap the benefits of using "vectorised" functions in R but not big enough to create
memory problems. So this is how a sample call would look like, with the first argument being a sample dataset.

```r
recsize = 1000
kmeans(to.dfs(lapply(1:100, function(i) keyval(NULL, 
                                               cbind(sample(0:2, recsize, replace = T) + 
											   rnorm(recsize, sd = .1), 
                                                           sample(0:3, recsize, replace = T) + 
                                                             rnorm(recsize, sd = .1))))), 
															 12, iterations = 5, fast = T)
```

This creates and operates on a dataset with 100,000 data points, organized in 100 records. For a larger data set you would need to increase
the number of records only, the size of each record can stay the same. As you may recall, the implementation of kmeans we described in the
tutorial was organized in two functions, one containing the main iteration loop and the other doing the work of computing distances and new
centers. The good news is the first function can stay exactly the same but for the addition of a flag that tells whether to use the
optimized version of the "inner" function, so we don't need to cover it here (the code is un the source under tests, only in dev branch for
now). Therefore we only need to define a `kmeans.iter.fast` as an alternative to `kmeans.iter` in the implementation in the Tutorial. OK,
there is also a small different in the `kmeans` function, I will explain that in a moment. On of the most CPU intensive tasks in this
algorithm is computing distances between a candidate center and each data point. If we don't implement this one in an efficient way, we
can't hope for an efficient algorithm. Since it takes about a microsecond to call the simplest function in R, we need to get a significant
amount of work done for each call. Therefore, instead of specifying the distance function as a function of two points, we will switch to a
function of one point and and a set thereof that returns that distance between the first argument and each element of the second. In this
implementation we will us a matrix instead of a set, since there are powerful primitives available to operate on matrices. The following is
the default distance function with this new signature, where we can see that we avoided any loops over the rows of the matrix `yy`. There
are two implicit loops (`Reduce` and `lapply`) but internally they used vectorized operators.


```r
    fast.dist = function(yy, x) { #compute all the distances between x and rows of yy
      squared.diffs = (t(t(yy) - x))^2
      ##sum the columns, take the root
      sqrt(Reduce(`+`, lapply(1:dim(yy)[2], function(d) squared.diffs[,d])))} #loop on dimension
```



```r
kmeans.iter.fast = 
function(points, distfun = fast.dist, ncenters = dim(centers)[1], centers = NULL) {
```


The following is a function that computes all the distance between a set of points represented as the matrix `yy` and a single points
`x`. Compared to the slow version, we've lost the generality w.r.t the distance function.

```r
    list.to.matrix = function(l) do.call(rbind,l) # this is a little workaround for RJSONIO not handling matrices properly
    newCenters = from.dfs(
      mapreduce(
        input = points,
        map = 
          if (is.null(centers)) {
            function(k, v) {
              v = cbind(1, list.to.matrix(v))
              ##pick random centers
              centers = sample(1:ncenters, dim(v)[[1]], replace = TRUE) 
              clusters = unclass(by(v,centers,function(x) apply(x,2,sum)))
              lapply(names(clusters), function(cl) keyval(as.integer(cl), clusters[[cl]]))}}
          else {
            function(k, v) {
              v = list.to.matrix(v)
              dist.mat = apply(centers, 1, function(x) fast.dist(v, x))
              closest.centers = as.data.frame(
                which( #this finds the index of the min row by row, but one can't loop on the rows so we must use pmin
                  dist.mat == do.call(
                    pmin,
                    lapply(1:dim(dist.mat)[2], 
                           function(i) dist.mat[,i])), 
                  arr.ind=TRUE))
              closest.centers[closest.centers$row,] = closest.centers
              v = cbind(1, v)
              clusters = unclass(by(v,closest.centers$col,function(x) apply(x,2,sum))) #group by closest center and sum up, kind of an early combiner
              lapply(names(clusters), function(cl) keyval(as.integer(cl), clusters[[cl]]))}},
       reduce = function(k, vv) {
               keyval(NULL, apply(list.to.matrix(vv), 2, sum))},
     reduceondataframe = F,
     combine = F),
todataframe = T)
    ## convention is iteration returns sum of points not average and first element of each sum is the count
    newCenters = newCenters[newCenters[,1] > 0,]
    (newCenters/newCenters[,1])[,-1]}
```
