## Introduction

The central data type for rmr is the **key-value pair**. It is a list of any two R objects with an attribute `"rmr.keyval"` set to `TRUE`, created with the `keyval` function. Data sets in mapreduce are seen as collections of key-value pairs. There is an alternate way to represent data sets which is the vectorized key-value pair, which is created with the same `keyval` function with a third argument `vectorized` set to TRUE and has an "rmr.vectorized" attr set to TRUE. This means that the key and value are construed as collection of elementary keys and rows resp. In this case a key or value can be an atomic vector, atomic matrix or data frame with atomic columns. If it has rows ( `nrow` doesn't return NULL), then each row `[i,]` is considered a key, otherwise each element as returned by `[[i]]`, `i` an integer within the appropriate range. The same is true for values. The number of elementary keys and values in a pair has to be the same. 


## Motivation

The reason vectorized key-value pairs exist is efficiency. It's a lot faster to call `keyval(1:10^6, 1:10^6)` than `lapply(1:10^6, function(i) keyval(i,i))`, namely 163 times faster on some systems. For the same reason, vectorized key-value pairs are serialized using a simple serialization format called *typedbytes* instead of R's own format, which doesn't have support for matrices, data frames or atomic vectors, which are converted into lists (row first). Using vectorized key-value pairs is particularly important as return values for the map  and combiner functions, as the precise definition of what the keys are defines the grouping in the combine/reduce phase. Elsewhere it's probably better to avoid them. Lists of vectorized key-value pairs are possible.

## Definitions and Invariants
 1. Record extraction (any R data structure): 

   ```
   record(x, n) if(is.null(nrow(x))) x[[n]] else x[n, ]
   ```
 2. Number of records in a key-value pair:

  ```
  nrecords(x) = if(is.null(nrow(x)) length (x) else nrow(x))
  keyval(x,y, vectorized = true)` $\Rightarrow$ `nrecords(x) == nrecords(y)
  ```
 
 3. Key extraction :

   ```
   keys(keyval(k,v) == list(k); values(keyval(k,v)) == list(v)
   ```
 4. Concatenation:

   ```
   keys(list(keyval(k1, v1), keyval(k2,v2)) == list(k1, k2)
   ```
   Same for `values` and longer lists
 5. Immersion of vectorized key-value pairs into regular ones:  

   ```
   keys(keyval(k, v)) == keys(keyval(list(k), list(v), vectorized = TRUE))
   ```
   Same for `values`.
 6. Reverse immersion:

   ```
  keys(lapply(1:n, function(i) keyval(record(kk, i), record(vv, i )))) 
  == keys(keyval(kk, vv, vectorized = TRUE))
   ```
   Same for `values`.
 1. Merger of vectorized keyval pairs:

   ```
   keys(list(keyval(kk1,vv1, vectorized = TRUE), keyval(kk2, vv2, vectorized = TRUE))) 
   == keys(keyval(c.or.rbind(kk1,kk2), c.or.rbind(vv1, vv2)))
   ```
   where
   ```
   c.or.rbind = 
   function(x,y) {
     switch(is.null(nrow(x)) + is.null(nrow(y)),
            c(x, y),
            stop("Incompatible data structures"),
            rbind(x,y))}
  ```
  Please note that `c.or.rbind` can fail in any other number of ways, for instance when applied to data frames or matrices with different number of columns.
  
## Structured view
  This can be applied at the user request to any list of keys or values and it is equivalent to `c.or.rbind` above
  
## Limitations
  Because of the limitations of the `typedbytes` serialization format, vectorized key-value pairs are limited to contain atomic vectors and matrices and data frames with atomic columns. Some meta-data is lost during serialization and therefore the user needs to pr
    
