We have covered a basic k-means implementation with `rmr` in the [Tutorial]. But if you tried it out you probably have noticed that its performance leaves to be desired and wonder if anything can be done  about it. Or your have read [Efficient rmr techniques] and would like to see those suggestions put to work beyond the trivial "large sums" example used therein. You are in the right place since we will cover an implementation that is modestly more complex and is 200x faster.


```r
kmeans(to.dfs(lapply(1:100, function(i) keyval(NULL, 
                                               cbind(sample(0:2, recsize, replace = T) + rnorm(recsize, sd = .1), 
                                                           sample(0:3, recsize, replace = T) + 
                                                             rnorm(recsize, sd = .1))))), 12, iterations = 5, fast = T)
```


```r
kmeans.iter.fast = 
function(points, distfun = NULL, ncenters = dim(centers)[1], centers = NULL) {
    fast.dist = function(yy, x) { #compute all the distances between x and rows of yy
      squared.diffs = (t(t(yy) - x))^2
      ##sum the columns, take the root
      sqrt(Reduce(`+`, lapply(1:dim(yy)[2], function(d) squared.diffs[,d])))} #loop on dimension
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