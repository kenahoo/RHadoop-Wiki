# Design for rmr.ez

## Status

Early draft. Evertyhing can and perhaps should change, bar the overarching goal. Everything is game for critique and alternatives. Brainstorming, within reason, is allowed.

## Goals

### Overarching goal
**Capture important subsets of rmr2 use cases while making it easier to use**
alternative: fold back changes into rmr2 if loss of generality can be avoided

### Specific goals
* make the key value concept go away
* as a consequence, the equivalent of map and reduce functions have only one argument
* the `keyval` function is banned from the API 

## How
* focus on data.frames for now (matrix support should be automatic)
* map and reduce can be single argument functions. If key is present it is either discarded or cbinded (alternative). If they are numeric or string, they are used as column selection.
* if map or reduce return a data frame or a matrix, those are passed along. If they return logical or numeric, that's a filter (alternative, have a separate argument called `filter` to make this use more explicit. Must be specified instead of `transform`)
* the mapreduce equivalent has an additional `group.by` argument
   * if it is an integer or a string, it selects a column and that column is used as keys
   * if it is a function, it is applied to the only map argument and the return values used as keys
   * several predefined options: random reducer, single reducer, hash, bins?
* `from.dfs` is redefined as `function(x) values(from.dfs(x))`. Alternative: `function(x) do.call(cbind, from.dfs(x))`

##API

I am going to make a fool of myself here trying to rename concepts in mapreduce. The idea is not try to sell this more than a different take on the API but to avoid confusion with `rmr2`. `mapreduce` is replaced by `transfold` (transform and fold), `map` by `transform` and `reduce` by `fold`. These are synonyms in the functional programming literature, I just wanted to change names.

```
transfold = function(input, output, transform, group.by, fold)
```

## Use cases

Assume 

```
input = to.dfs(mtcars)
constant(k =  1) function(x) k
altogether = constant()
random = function(x) runif(nrow(x))
hash = function(index, range) function(x) apply(x[,index],2, cksum)%%range
```

### Identity

```
transfold(input)
```
or equivalently

```
transfold(input, transform = identity)
```

or equivalently

```
transfold(input, transform = function(x) x)
```

Best form is the shortest, but the others are there to explain what happens and suggest how to write on transformer.

### Filter

`predicate` is as a function of a data.frame that takes logical or numeric values 
```
predicate = function(x) x[,1]%%4 == 0
transfold(input, transform = predicate)
```

### Select

```
transfold(input, transform = c("mpg", "cyl"))
```

or equivalently

```
transfold(input, transform = 1:2)
```

or equivalently

```
transfold(input, transform = function(x) x[,1:2])
```

### Sum

```
transfold(input, transform = colSums, group.by = altogether, fold = colSums)
```

problem: need to activate the combiner here, that is necessary but also advanced
solution: have a switch like is.fold.associative.and.commutative that turns on the combiner when TRUE but talks about the condition to verify, not the specific optimization

### Group and aggregate

``` 
transfold(input, group.by = "cyl", fold = colSums)

```

or equivalently

```
transfold(input, group.by = 1, fold = colSums)
```

or equivalently

```
transfold(input, group.by = function(x) x$cyl, fold = colSums)
```

### Wordcount

`input` here is some text. We are ignoring the input format issue for now.

```
wordcount =
  function(
    input,
    output = NULL,
    pattern = " ") {
    wc.transform  = 
      constant(1)
    wc.group.by = 
      function(x) 
        unlist(
          strsplit(
            x = x[,1], 
            split = pattern))
    transfold(
      input = input,
      output = output,
      transform = wc.transfowm,
      group.by = altogether,
      fold = wc.fold)}
```

### Logistic Regression

```
logistic.regression = 
  function(input, iterations, dims, alpha) {
   lr.transform =          
    function(M) {
      Y = M[,1] 
      X = M[,-1]
      Y * X * 
        g(-Y * as.numeric(X %*% t(plane)))}
  lr.fold =
    function(Z) 
      t(as.matrix(apply(Z,2,sum)))
  
    plane = t(rep(0, dims))
    g = function(z) 1/(1 + exp(-z))
    for (i in 1:iterations) {
      gradient = 
        values(
          from.dfs(
            transfold(
              input,
              transform = lr.transform,
              group.by = altogether,
              fold = lr.fold)))
      plane = plane + alpha * gradient }
    plane }
```

### k-means
  

##Implementation

```
transfold = 
  function(
    input,
    output = NULL,
    transform = identity, 
    group.by = 1,
    fold = NULL)
    rmr2::mapreduce(
      input = input,
      output = output,
      map = make.mr.fun(transform, group.by),
      reduce = make.mr.fun(fold))
```

```
can.index = function(x) is.numeric(x) || is.character(x) || is.logical(x)
make.mr.fun = 
  function(f, group.by = NULL)
    if(is.null(f)) NULL 
    else
      if(can.index(f))
        make.mr.fun(function(x) x[,f])
      else  
        function(k, v) {
          k1 = {
            if(is.null(group.by)) NULL
            else {
              if(is.function(group.by)) group.by(v)
              else (v[, group.by])}}
          v1 = f(v)
          if(can.index(v1)))
            keyval(k1[v1,], v[v1,])
          else keyval(k1, v1)}
```      

```
make.group.by()
