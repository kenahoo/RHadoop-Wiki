# Planning for Multiple Output Feature

## Goal

We need to create two distributed collections from a single computation.

## Motivation

Computing the distributed collections one at a time requires re-reading the same inputs or performing twice the same computation. This is a performance issue

## Use case

Stochastic SVD: in one job, the QR factorization of blocks of a matrix A are computed. The Q matrix is written in the map in "side files" (in java written using the MultipleOutputs class), the products Qi Ai go to the reduce phase. This achieves not reading A twice and not doing the QR twice.


## Challenges

1. Writing two outputs breaks or at least stretches the functional model. Functions return one value, albeit potentially complex.
2. More specifically, our model for mapreduce has been the pair lapply/tapply. Both return one list
3. Even more distressing in the SVD use case is that one output skips the reduce phase and one doesn't. Could implement with two classes of keys, one that gets processed and the other that gets through an identity reduce, but it doesn't avoid unecessary shuffle phase work. This is implemented with class MultipleOutputs which doesn't have a streaming equivalent. That's a show stopper for the SVD case. Of course one can implement it with 2 additonal jobs no problem.
4. The streaming API commingles the concept of multiple outputs with the concept of key, which is supposed to contain the name of the output and with the concept of format, which should be absolutely orthogonal. Not only this is not up to the standards of rmr2 but also collides with the fact that keys, when serialized natively, are opaque for Java


## Proposed API

1. mapreduce returns one ore more big data objects, paths or combination thereof
2. If output is specified as a named character vector, the different outputs are written to the specified paths. The names are used in the name and reduce function to write to the right output. 
3. If output is NULL, current default is single output, if it is a named list of NULLS, big data objects are returned for those NULLs

```
mapreduce(input = ..., output = list(Q = "/user/rhadoop/SVD/Q"), QA = NULL), ...)
```

In this case `Q` and `AQ` would be used as labels in the map and reduce functions to refer to the different outputs, the first output is explicit, the second is a big data object
4. From the map and the reduce function, one has an additional primitive "multi" which takes one or more argument, all keyval pairs or coerced to keyval pairs if they are anything else, the arguments are named like the output list. In the example

```
map = 
  function (k,v) {
    Q = qr.Q(qr(v))
    multi(Q = keyval(1, Q), QA = keyval(1, Q%*%A)), 
```

As I understand MultipleOutputFormat, `multi` could be used only in the reducer or the mapper in a map-only job. We lost our only use case because there there are multiple output in the map phase of a map-reduce job with a nontrivial reduce.

## Proposed implementation

When multiple outputs are present the output format class defaults are changed to MultipleSequenceOutputFormat or MultipleTextOutputFormat. It's true the user can override this and creat havoc, that's a problem. When writing a `multi` object of course the operation is broken down into writing each of the member keyval pairs. The key is extended with the name of the output file. The output class reads that information and writes to the appropriate file (adding the part-XXXXX subpath to avoid concurrent writing). The key is stripped of the filename information and restored to what the user expects it to be.

