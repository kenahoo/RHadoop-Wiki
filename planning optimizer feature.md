# Planning optimizer feature

## Overview
The idea is to transform expression or set of expressions involving mapreduce calls to achieve better performance, particularly minimize I/O and number of jobs. Pig, Hive have this feature, called a plan optimizer or some such. Apparently Cascading, despite claims to the opposite, doesn't have more than a trivial one (I read the class call Planner and there are not optimizations in there, Jeff Hammerbacher says as much in a Quora post). Therefore we have a challenge of attempting this kind of optimizations on a full fledged programming language maybe for the first time -- if anybody reading this has counterexamples please share. 

## Transformations
We have identified three expression transformations that could be applyed. `mapreduce` here is `mr` for short and we rely on identifiers naming to keep expression simpler. This is not and will not become real code. The overall impact of these transformations on actual algorithms remains to be seen. We could for instance review existing rmr examples and try to anticipate the I/O work reductions. My intuition is that these techniques apply best to complex DAGs typical of ETL and data source integration and denormalization and not to simple iterative algorithms such as kmeans

### map only chain
turn a chain of jobs of which only the last one has a reduce phase into a single job

```
mr(mr(in, map1), map2, reduce) => mr(in, Compose(map2,map1), reduce)
```

### map only shared input

execute two map only jobs that read the same input as the same input using the multiple output format

```
mr(in, out1, map1); mr(in, out2, map2) => mr(in, list(out1, out2), Parallel(map1, map2))
```

This requires extending mr to multiple outputs and integrating the necessary Java classes (this would be of independent value and could be use directly by users, for instance to create "side outputs" in complex algorithms such as SVD decomposition)

### shared map shared input

Two jobs with same input and map function but different reduce

mr(i, o1, map, reudce1); mr(i,o2, map, reduce2) => mr(i, list(o1,o2), map, Parallel(reduce1, reduce2))

### Delayed map transformation

A tranformation that doesn't per se provide any I/O advantages but should incread the applicability of the above is when the map function can be split into a key computation, say `group` and a value computation, say `transform`, as in `function(k,v) keyval(group(k,v), transform(k,v))`. Then we can delay the transformation and simplify the map to just `group.map = function(k,v) keyval(group(k,v), data.frame(key=asIs(k), val = asIs(v)))` or some such and apply the following rule

```
mr(i, map, reduce) => mr(i, group.map, Compose(reduce, transform))
```

Now if two jobs share the same input and group function but differ in transform, by delaying the transform part we can apply the above rule


## API
The goal would be to make this development possible with no changes to the API or, failing that, only backwards compatible changes. Keeping the semantics absolutely unchanged seems an unattainable goal as, for instance, two map functions can share references to a mutable environment and delaying their evaluation means they would see a potentially different environment. Snapshotting multiple environments and restoring them as needed seems difficult and downright impossible once efficiency is factored in. Imagine that we are applying the fist rule, map only chain. If map1 and map2 are the same functions but differ in their semantic because of a reference to the same mutable environment, composing them would require constantly swapping environment. Here is an example of this phenomenon


```r
f = function(x) x + delta
delta = 1
tmp = sapply(1:5, f)
tmp
```

```
## [1] 2 3 4 5 6
```

```r
delta = 2
sapply(tmp, f)
```

```
## [1] 4 5 6 7 8
```

```r
sapply(1:5, function(x) f(f(x)))
```

```
## [1] 5 6 7 8 9
```

```r
delta = 1
sapply(1:5, function(x) f(f(x)))
```

```
## [1] 3 4 5 6 7
```


We are in a bind. We need to apply `f` twice with two different values of delta. Defining two functions won't help as environments are not copied and anyway there is only one global environment. This is less artificial of an example than it may seem. Imagine we want to filter the data for pattern A and the for pattern B and the role of the variable `delta` is now to hold that pattern. One way out is to explain to the user that this is not allowed and that to use the optimizer one has to eliminate side effects between jobs.  In fact the solution is "better" than the original (at least, it looks more reusable to me)


```r
plus = function(delta) function(x) x + delta
tmp = sapply(1:5, plus(1))
tmp
```

```
## [1] 2 3 4 5 6
```

```r
sapply(tmp, plus(2))
```

```
## [1] 4 5 6 7 8
```

```r
sapply(1:5, function(x) plus(2)(plus(1)(x)))
```

```
## [1] 4 5 6 7 8
```


## Implementation plan
We need to delay the evaluation of a mapreduce call to happen only when necessary (the biggest the DAG of MR jobs, the more the opportunities for optimization). One forcing event is a from.dfs call. Another could be specifying an output explicitly, as optimization could "dematerialize" that step of the computation (it gets computed but never gets written). Using R promises expose us to the vagaries of the built in mechanism, which is way too eager to be of more than limited usefulness. We need to add a third possiblity for a big data object: path, temp object, delayed mapreduce expression. mapreduce could have an additional argument, not exposed to the user, `eager`. When `eager` is `TRUE` everything works as it does in 2.1. When it's `FALSE`, the return value is the call itself (see `match.call`), possiby with a pointer to the the saved eval environemnt, to freeze the current calling environment and side-step its mutability (but see above, I still see this as an unattainable goal if performance is taken into account). 


```r
f = function(x, eager = FALSE) if (eager) eval(x) + 1 else {
    z = match.call()
    z$eager = T
    z
}
f(2)
```

```
## f(x = 2, eager = TRUE)
```

```r
f(2, F)
```

```
## f(x = 2, eager = TRUE)
```

```r
f(2, T)
```

```
## [1] 3
```

```r
eval(f(2))
```

```
## [1] 3
```

```r
f(f(0, T), T)
```

```
## [1] 2
```

```r
f(f(0, F), F)
```

```
## f(x = f(0, F), eager = TRUE)
```

```r
f(f(0))
```

```
## f(x = f(0), eager = TRUE)
```

```r
eval(f(f(0)))
```

```
## [1] 2
```


A general lazy-fying function could be:

```r
lazy = function(f) function(eager = FALSE, ...) if (eager) do.call(f, lapply(list(...), 
    eval)) else {
    z = match.call()
    z$eager = T
    z
}
g = function(x) x + 1
h = lazy(g)
h(T, 1)
```

```
## [1] 2
```

```r
h(T, 2)
```

```
## [1] 3
```

```r
h(F, 0)
```

```
## h(eager = TRUE, 0)
```

```r
eval(h(F, 0))
```

```
## [1] 1
```

```r
h(F, h(F, 0))
```

```
## h(eager = TRUE, h(F, 0))
```

```r
eval(h(F, h(F, 0)))
```

```
## [1] 2
```





A forcing event would transform the complex expression thus assembled and apply the transformations listed above (in an arbitrary order on a first cut), then recursively force evaluation. One problem with this plan is that some optimizations only apply to two or more mapreduce expressions (for instance, the one sharing the same input). So we need to optimize them simultaneously, but the forcing event is defined for a single expression. We need to assemble a list of all delayed mapreduce expression at a time of a forcing event and optimize them together and then force the part of the resulting graph that needs to be evaluated to resolve the forcing. This seems quite a project.
