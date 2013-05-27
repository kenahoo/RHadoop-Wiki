# Design for rmr.ez

## Status

Early draft. Evertyhing can and perhaps should change, bar the overarching goal. Everything is game for critique and alternatives. Brainstorming, within reason, is allowed.

## Goals

### Overarching goal
**Capture important subsets of rmr2 use cases while making it easier to use**.
Alternative: fold back changes into rmr2 if loss of generality can be avoided.

### Specific goals
* make the key value concept go away
* as a consequence, the equivalent of map and reduce functions have only one argument
* the `keyval` function is removed from the API 

## How
* focus on data frames for now (matrix support should be automatic)
* map and reduce can be single argument functions. If key is present it is either discarded or cbinded (alternative: discarding seems untenable, see wordcount example, need to explore cbinding). If they are numeric or string, they are used as column selection.
* if map or reduce return a data frame or a matrix, those are passed along. If they return logical or numeric, that's a filter (alternative, have a separate argument called `filter` to make this use more explicit. Must be specified instead of `transform`)
* the mapreduce equivalent has an additional `group.by` argument
   * if it is an integer or a string, it selects a column and that column is used as keys
   * if it is a function, it is applied to the same data as `transform` or `fold` and the return values used as keys
   * several predefined options: random reducer, single reducer, hash, bins?, quantiles
* `from.dfs` is redefined as `function(x) values(from.dfs(x))`. Alternative: `function(x) do.call(cbind, from.dfs(x))`

## API concepts
We are exploring several choices. The first choice is whether we should have a transform argument that's overloaded with the potential to act as a filter and column selector and resampler tasks or several separate arguments. Since you can pass a function to transform, you can always achieve these effects similarly to a map function in rmr2 but the question is whether to have some API footprint for these common uses or infer the right on from the arguments or their return values when they are functions. There are fairly simple and clear cut rules for it so it's not a quagmire as it may seem. On the other hand multiple arguments raise the question of how to execute them when they are specified simultaneously. The second choice is based on a recognition that when the map function is vectorized, it is in fact another reduce, albeit with no guaranteed grouping. Particularly when the grouping is trivial, one can and should start aggreagation as early as possible, that is in map.

## Alternate API 1

I am going to make a fool of myself here trying to rename concepts in mapreduce. The idea is not try to sell this more than a different take on the API but to avoid confusion with `rmr2`. `mapreduce` is replaced by `transfold` (transform and fold), `map` by `transform` and `reduce` by `fold`. These are synonyms in the functional programming literature, I just wanted to change names.

```
transfold = function(input, output, transform, group.by, fold)
```

## Use cases

Assume 

```
input = to.dfs(mtcars)
constant(k = 1) function(x) k # 1 because it can be used as a counter.
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

ALERT! There is a serious problem here in writing wordcount, particularly `wc.fold`. wc.fold needs access to the key, but in one of our design options the key is dropped as a secondary argument. But the problem is, we can not include it in the value for performance and style reasons, because all the computational work is done in the `group.by` function and we can't specify it twice and execute it twice, plus the I/O penalty of having the same information in the key and in the value. It didn't take a long time to find an example that strongly suggest that dropping the key from the API is not a very good idea. The alternative to dropping was to cbind it with the value, so as to present the same information to the user but ina simpler single data frame form. But it is simpler so to speak, since it has more columns that the user himself specified in the transform. The fine tradeoffs remain to be hashed out, but dropping information doesn't seem to be an option.

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
  

## Implementation


Implementation here is only to clarify semantics and highight possible difficulties, it's not tested even in the sense of being valid R.

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

## Alternate API 2

The astute reader may have noticed that the `transform` argument in the above API is used generally for anything like a real transformation in the STL sense (function from a collection of N elements to a collection of other N elements),  a filter (from a collection of `N` elements to `n < N`) where elements in the output are equal to some in the input, a resampler, where length can increase or decrease but each element in output is equal to some element in input and finally a select in the SQL sense, which is a special transformation also known as a projection. The specific behavior is decided based on the type of the argument passed to `transform` and, if that is a function, its return type. This has the effect of making the API smaller but also can be terse (if it is a filtering action I want to accomplish, why should I call it a `transform`) and limiting in that one can effect all those types of transformation at the same time using the functional argument, but only by writing a more complex function. At the same time, if we let the user specify all of these arguments at once, we need to apply them in a certain order. This order can be arbitrary, hence confusing to the user and also may imply loss of generality. So here I will try to make the opposite choice and see what happens.


```
transfold = function(input, output, transform = identity, filter = T, select = T, resample = T, group.by, fold)
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
transfold(input, filter = predicate)
```

### Select

```
transfold(input, select = c("mpg", "cyl"))
```

or equivalently

```
transfold(input, select = 1:2)
```

or equivalently

```
transfold(input, select = function(x) x[,1:2])
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
  

## Implementation

Implementation here is only to clarify semantics and highight possible difficulties, it's not tested even in the sense of being valid R.

```
transfold = 
  function(
    input,
    output = NULL,
    transform = identity
    select = T,
    filter = T,
    resample = T,
    group.by = 1,
    fold = NULL)
    rmr2::mapreduce(
      input = input,
      output = output,
      map = make.mr.fun(transform, filter, select, resample, group.by),
      reduce = make.mr.fun(fold))
```

```
make.mr.fun = 
  function(transform, filter, select, resample, group.by = NULL)
    function(k, v){
      if(!is.function(filter))
        filter = constant(filter)
      if(!is.function(resample))
        resample = constant(resample)
      v = v[filter(v),]
      v = v[select,]
      v = transform(v)
      keyval(
        if(is.null(group.by)) NULL
          else {
            if(is.function(group.by)) group.by(v)
            else (v[, group.by])},
        group.by(v))}
```      

## Alternate API 3

Here we try to highlight the symmetry between map and reduce, thus inviting the developer to aggregate early when possible. Also we apply the same rules to construe the reduce function as a transformation, filter or select. Of course the name transfold, already ugly, makes less sense because there is no fold argument. Call it `the.function.formerly.known.as.mapreduce` if you want.


```
transfold = function(input, output, transform = identity, group.by = NULL, group.transform = NULL)
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
transfold(input, filter = predicate)
```

### Select

```
transfold(input, select = c("mpg", "cyl"))
```

or equivalently

```
transfold(input, select = 1:2)
```

or equivalently

```
transfold(input, select = function(x) x[,1:2])
```

### Sum

```
transfold(input, transform = colSums, group.by = altogether, group.transform = colSums)
```

problem: need to activate the combiner here, that is necessary but also advanced
solution: have a switch like is.fold.associative.and.commutative that turns on the combiner when TRUE but talks about the condition to verify, not the specific optimization

### Group and aggregate

``` 
transfold(input, group.by = "cyl", group.transform = colSums)

```

or equivalently

```
transfold(input, group.by = 1, group.transform = colSums)
```

or equivalently

```
transfold(input, group.by = function(x) x$cyl, group.transform = colSums)
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
      group.transform = wc.group.transform)}
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
  

## Implementation

Implementation here is only to clarify semantics and highight possible difficulties, it's not tested even in the sense of being valid R.

```
transfold = 
  function(
    input,
    output = NULL,
    transform = identity
    select = T,
    filter = T,
    resample = T,
    group.by = 1,
    fold = NULL)
    rmr2::mapreduce(
      input = input,
      output = output,
      map = make.mr.fun(transform, filter, select, resample, group.by),
      reduce = make.mr.fun(fold))
```

```
make.mr.fun = 
  function(transform, filter, select, resample, group.by = NULL)
    function(k, v){
      if(!is.function(filter))
        filter = constant(filter)
      if(!is.function(resample))
        resample = constant(resample)
      v = v[filter(v),]
      v = v[select,]
      v = transform(v)
      keyval(
        if(is.null(group.by)) NULL
          else {
            if(is.function(group.by)) group.by(v)
            else (v[, group.by])},
        group.by(v))}
```      