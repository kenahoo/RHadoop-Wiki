# Design for rmr.ez

## Goals

### Overarching goal
* Capture important subsets of rmr2 use cases while making it easier to use

### Specific goals
* make the key value concept go away
* as a conseqence, the equivalent of map and reduce functions have only one argument
* the `keyval` function is banned from the api 

## How
* focus on data.frames for now (matrix support should be automatic)
* map and reduce are single argument functions. If key is present it is either discarded or cbinded
* if map or reduce return a data frame or a matrix, those are passed along. If they return logical or numeric, that's a filter
* mapreduce or whatever the name has an additional group.by argument
   * if it is an integer or a string, it selects a column and that column is used as keys
   * if it is a function, it is applied to the only map argument and the return values used as keys
   * several predefined options: random reducer, single reducer, hash, bins?



##Implementation

```
mapreduce = 
  function(
    input,
    output = NULL,
    transform = identity, 
    group.by = 1,
    fold = identity)
    rmr2::mapreduce(
      input = input,
      output = output,
      map = make.mr.fun(transform, group.by),
      reduce = make.mr.fun(fold))
```

```
make.mr.fun = 
  function(f, group.by = NULL)
    function(k, v) {
      k1 = {
        if(is.null(group.by)) NULL
        else {
          if(is.function(group.by)) group.by(v)
          else (v[, group.by])}}
      v1 = transform(v)
      if(is.logical(v1) || is.numeric(v1))
        keyval(k1[v1,], v[v1,])}
```      