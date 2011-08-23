# Map Reduce in R

<a name="myfirstmapreducejob">
## My first mapreduce job

Conceptually, mapreduce is not very different than a combination of lapplys and a tapply: transform elements of a list, comput an index &mdash; key in mapreduce jargon &mdash; 
and process the groups thus defined. Let's start with the simplext example, from a simple lapply:
 
    small.ints = 1:10
    out = lapply(small.ints, function(x) x^2)

The example is trivial, just computing the first 10 squares, but we just want to get the basics here, there are interesting examples later on. Now to the mapreduce equivalent:

    small.ints = rhwrite(1:10)
    out = revoMapReduce(input = small.ints, map = function(k,v) keyval(k^2))
	
And this is it. There are some difference that we will go through, but the first thing to notice is that it isn't all that different, and just two lines of code. There are some superficial differences and
some more fundamental ones. The first line puts the data into HDFS, where the bulk of the data has to be for mapreduce to operate on. Of course, we are unlikely to write out big data with
`rhwrite`, certainly not in a scalable way. `rhwrite` is nontheless very useful for a variety of niche or not so niche uses like writing test cases, REPL and HPC-type uses of mapreduce &mdash; that
is, small data but big CPU demands. `rhwrite` can put the data in a file of your own choosing, but if you don't specify one it will create tempfiles and clean them up when done. The return value is
a an object that you can use as a "big data" object. You can assign it to variables, pass it to functions, mapreduce jobs or read it back in. Now onto the second line. It has `revoMapReduce` replace
`lapply`. We prefer named arguments with `revoMapReduce` because there's quite a few possible arguments, but one could do otherwise. The input is the variable `out` which contains the output
of `rhwrite`, that is our small number data set in its HDFS version, but there are other choices as we will see. The function to apply, which is called a map function in contrast with the reduce
function, which we are not using here, is a regular R function with a few constraints:

1. It's a function of two arguments, a key and a value
1. It returns a key value pair as returned by the helper function `keyval`, which takes any one or two R objects as arguments &mdash; the second defaults
to `NULL`; you can also return a list of such objects, or `NULL`.
In this example, we are not using the value at all, only the key, but we still need both to support the general mapreduce case. Ther return value is a 
big data object just like the one returned by `rhwrite`, so you can read it into memory with `rhread(out)` or use it as input to other jobs as in 
`revoMapReduce(input = out, ...)`. `rhread` is the complement to `rhwrite`. It returns a list of key-value pairs, which is the most general data type
that mapreduce can handle. If you prefer data frames to lists, a data frame interface is in the works which is of course not fully general but covers 
very important use cases.

The return value is an object, actually a closure, and you can pass it as input to other jobs or read it into memory (watch out, not good for big data) with rhread. `rhread` is the dual of `rhwrite`. It returns a list of key value pairs, which is the most general data type that mapreduce can handle. If you prefer data frames to lists, we are working on a simplified interface that accepts and returns data frames instead of lists of pairs, which will cover many many important use cases. `rhread` is useful in defining practical map reduce algorithms whenever a mapreduce job produces something of reasonable size, like a summary, that can fit in memory and needs to be inspected to decide on the next steps, or to visualize it.

<a name="mysecondmapreducejob">
## My second mapreduce job

We've just created a simple job that was logically equivalent to a lapply but can run on big data. That job had only a map. Now to the reduce part. The closest equivalent in R is arguably a tapply. So here is the example from the R docs:

    groups = rbinom(32, n = 50, prob = 0.4)
    tapply(groups, groups, length)

This creates a sample from the binomial and counts how many times each outcome occurred. Now onto the mapreduce  equivalent:

    groups = rhwrite(groups)
    revoMapReduce(input = groups, reduce = function(k,vv) keyval(k, length(vv)))

First we move the data into HDFS with `rhwrite`. As we said earlier, this is not the normal way in which big data will enter HDFS; it is normally the responsibility of scalable data collection systems such as Flume or Sqoop. In that case we would just specify the HDFS path to the data as input to `revoMapReduce`. But in this case the input is the variable `groups` which points to where the data is temporarily stored, and the naming and clean up is taken care of for you. All you need to know is how you can use it. There isn't a map function, so it is set to default which is like an identity but consistent with the map requirements, that is `function(k,v) keyval(k,v)`. The reduce function takes two arguments, one is a key and the other is a list of all the values associated with that key. Like in the map case, the reduce function can return `NULL`, a key value pair as generated by the function `keyval` or a list thereof. The default is somewhat equivalent to an identity function, under the constraints of a reduce function, that is `function(k, vv) lapply(vv, function(v) keyval(k,v))`. In this case they key is one possible outcome of the binomial and the values are all `NULL` and the only important thing is how many there are, so `length` gets the job done. Looking back at this second example, there are some small differences with `tapply` but the overall complexity is very similar.

<a name="wordcount">
## Wordcount

The word count program has become a sort of "hello world" of the mapreduce world. For a review of how the same task can be accomplished in several languages, but always for map reduce, see this [blog entry](http://blog.piccolboni.info/2011/04/map-reduce-algorithm-for-connected.html).

<pre>
rhwordcount = function(input, output = NULL, <strong>pattern</strong> = " ") {
    revoMapReduce(input = input ,
        output = output,
        textinputformat = rawtextinputformat,
        map = function(k,v) {lapply(strsplit(x = v,split = <strong>pattern</strong>) &#91;&#91;1&#93;&#93;,
                                     function(w) keyval(w,1))},
         reduce = function(k,vv) {keyval(k, sum(unlist(vv)))},
         combine = T)}
</pre>

We are defining a function, `rhwordcount`, that encapsulates this job. This may not look like a big deal but it is important. Our main goal was not simply to make it easy to run a MR job but to make MR jobs first class citizens of the R environment and to make it easy to create abstractions based on them. For instance, we wanted to be able to assign the result of a MR job to a variable &mdash; and I mean *the result*, not some error code or diagnostics &mdash; and to create complex expressions including MR jobs. We take the first step here by creating a function that is itself a job, can be chained with other jobs, executed in a loop etc.  

Let's now look at the signature. There is an input and optional output and a pattern that defines what a word is for the user. 

The implementation is just a single call to `revoMapReduce`. Therein, the input can be an HDFS path, the return value of `rhwrite` or another job or a list thereof &mdash; potentially, a mix of all three cases, as in `list("a/long/path", rhwrite(...), revoMapReduce(...), ...)`. The output can be an HDFS path but if it is `NULL` some temporary file will be generated and wrapped in a big data object like the ones generated by `rhwrite`. In either event, the job will return the information about the output, either the path or the big data object. So we simply pass along the input and output of the`rhwordcount` function to the `revoMapReduce` call and return whatever it returns. That way the new function also behaves like a proper MR job &mdash; almost, more details [here](Writing-composable-mapreduce-jobs). The `textinputformat` argument allows us to specify a parser for the input. The default is a JSON-based format that can cover many different use cases, but not all R types (see the RJSONIO documentation for details). In this case we just want to read a text file, so the `rawtextinputformat` function will create key value pairs with a `NULL`key and a line of text as value. You can easily specify your own input and output formats and even support binary formats with the arguments `inputformat` and `outputformat`(the latter in the dev branch at the moment), but those take Java classes as values. 

The map function, as we know already, takes two arguments, a key and a value. The key here is not important, indeed always `NULL`. The value contains one line of text, which gets split according to a pattern. Here you can see that `pattern` is accessible in the mapper without any particular work on the programmer side and according to normal R scope rules. It is in bold to draw attention to the fact that `pattern` has to travel across R interpreters, machines, even racks and maybe one day even data centers to get from where it's initialized to where it's used and that happens not only without much fuss at all, but simply in keeping with normal scope rules. For each word, a key value pair (w, 1) is generated with `keyval` and the list of all of them is the return value of the mapper. 

The reduce function takes a key and a list of values as input and simply sums up all the counts and returns the pair word, count using the same helper function, `keyval`. Finally, specifying the use of a combiner is necessary to guarantee the scalability of this algorithm.

<a name="logisticregression">
## Logistic Regression

Now onto an example from supervised learning, specifically logistic regression by gradient descent. Again we are going to create a function that encapsulate this algorithm. 

<pre>
rhLogisticRegression = function(input, iterations, dims, alpha){
    <b>plane</b> = rep(0, dims)
    <b>g</b> = function(z) 1/(1 + exp(-z))
    for (i in 1:iterations) {
        gradient = rhread(revoMapReduce(input,
            map = function(k, v) keyval(1, v$y&lowast;v$x&lowast;<b>g</b> (-v$y&lowast;(<b>plane</b> %&lowast;% v$x))),
            reduce = function(k, vv) keyval(k,apply(do.call(rbind,vv),2,sum)),
            combine = T))
        plane = plane + alpha * gradient&#91;&#91;1&#93;&#93;$val }
    plane }
</pre>
    
As you can see we have an input with the training data. For simplicity we ask to specify a fixed number of iterations, but it would be marginally more difficult to implement a convergence criterion. Then we need to specify the dimension of the problem, which is a bit redundant because it can be inferred after seeing the first line of input, but we didn't want to put additional logic in the map function so it's a small compromise we are making and then we have the learning rate alpha.

We start by initializing the separating plane and defining the logistic function. As before, those identifiers are in bold because they will be used inside the map function, that is they will travel across interpreter and processor and network barriers to be available where the developer needs them and where a traditional, meaning sequential, R developer expects them to be available according to scope rules &mdash; 0 fuss and expected, powerful behavior.

Then we have the main loop where computing the gradient of the loss function is the duty of a map reduce job, whose output is brought straight into main memory with an rhread &mdash; there are temp files being created and destroyed behind the scenes but you don't need to know. The only important thing is that, reasonably, the gradient is going to fit in memory so we can do an rhread to get it with impunity.

This map reduce job has the input we specified in the first place, the training data. 

The map function simply computes the contribution of an individual point to the gradient. Please note the variables `g` and `plane` making their necessary appearance here without any work on the developer's part. The access here is read only but you could even modify them if you wanted &mdash; the semantics is copy on assign, which is consistent with how R works and easily supported by hadoop. Since in the next step we just want to add everything together, we return a dummy, constant key for each record.

The reduce function, besides the usual R fidgeting to get numbers out of lists, is just a big sum. As far as the fidgeting, we decided to support the more general lists first and then add some API convenience for the cases where a data frame would suffice, which is a special case but a very important one. The conversion is not as general as we would like it to be but you can try it (reduceondataframe = T, use dev version for best results).

Since we have only one key, all the work will fall on one reducer and that's not scalable, so in this example it's important to activate the combiner, in this case it's TRUE  so it's the same as the reducer. Since sums are associative and commutative that's all we need. We also support a distinct combiner function.

After the map reduce job is complete and `rhread` has copied the only record that is supposedly produced by this job into the gradient variable, we just have to upgrade the separating plane and return it after the iterations are complete.

To make this example production-level there are several things one needs to do, like having a convergence criterion instead of a fixed iteration number an an adaptive learning rate,  but probably gradient descent just requires too many iterations to be the right approach in a big data context. But this example should give you all the elements to be able to implement, say, conjugate gradient instead. In general, when each iteration requires I/O of a large data set, the number of iterations needs to be contained and algorithms with O(log(N)) number of iterations are natural candidates, even if the work in each iteration may be more substantial.

<a name="kmeans">
## K-means

We are now going to cover a simple but significant clustering algorithm and the complexity will go up just a little bit. To cheer yourself up, you can take a look at [this alternative implementation](http://www.hortonworks.com/new-apache-pig-features-part-2-embedding/) which requires three languages, python, pig and java, to get the job done and is hailed as a model of simplicity.

We are talking about k-means and we are going to implement it in two parts: a function that controls the iterations and termination of the algorithm and one, essentially a mapreduce job, that does the grunt work of computing distances and electing centers. This is not a production ready implementation, but should be illustrative of the power of this package. You simply can not do this in pig or hive alone and it would take hundreds of lines of code in java.

```
rhkmeans =
  function(points, ncenters, iterations = 10, 
           distfun = 
             function(a,b) norm(as.matrix(a-b), type = 'F')) {
    newCenters = rhkmeansiter(points, distfun = distfun, 
                       ncenters = ncenters)
    for(i in 1:iterations) {
      newCenters = lapply(getValues(newCenters), unlist)
      newCenters = rhkmeansiter(points, distfun, centers=newCenters)}
    newCenters}
```


This is the controlling program. Most of its lines are executed locally, meaning in the same interpreter where the main function is called. We define a function that  takes a set of points, a desired number of centers, a number of iterations (a convergence test would be better, just for illustration purposes) and a distance function defaulting to euclidean distance.

This function uses another function, `rhkmensiter` which implements one iteration of kmeans. It can be called in two flavors. In the first call, only the number of centers is specified. The function returns  a new set of centers.

Now let's look at the main loop. It gets executed a user set number of times, for simplicity's sake, but implementing a convergence criterion should be easy. The first line in the loop body is just turning a list into a matrix and doesn't really do anything interesting. The issue here, which we have already touched upon, is that in the general case map reduce jobs can return lists, but data frames or matrices are enough for very common cases including this one. We are working on changes in the API to accomodate this, so please don't let this line ruin your day.

Next is a call to the other flavor of `rhkmeansiter`, where a set of centers rather than just the number of centers is provided. and the return value is, as before, a new set of centers. Let's now look at `rhkmeansiter`

```
rhkmeansiter =
  function(points, distfun, ncenters = length(centers),
           centers = NULL) {
    rhread(
      revoMapReduce(input = points,
         map = if (is.null(centers)) {
                   function(k,v)keyval(sample(1:ncenters,1),v)}
               else {
                   function(k,v) {
                       distances = lapply(centers, 
                                          function(c) distfun(c,v))
                   keyval(centers\[\[which.min(distances)\]\],v)}},
         reduce = function(k,vv) keyval(NULL, 
	                                    apply(do.call(rbind, vv), 2, mean))))}
```

This is one iteration of kmeans, implemented as a map reduce job. We are already familiar with all the paramers to this function and we know what `rhread` does, in this case it moves new cluster centers computed by a mapreduce job and stored in HDFS into main memory. Here we are assuming we have a lot of points, as in big data, but a small number of centers, as in they fit in RAM. It's a common case but it might not cover all applications.

Next is the call actually performing a map reduce job. Its input is a set of points, as an HDFS path or big data object. We have two cases  for the map function, one for the initialization, that is when there isn't a set of current cluster centers, only a desired number, and one for all the other calls from the main loop. In the former we just assign a random center to each point and generate a key value pair with the center as key and the point as value. That means, in the reduce stage, we are guaranteed that all points with the same center will end up together in the same reduce call. Of course that could mean that some reducers have an unacceptable amount of work to perform, but a simple modification of this program and the use of a combiner fixes that problem, so we are going to ignore it for this tutorial. In the latter we compute all the distances from a point to each center and return a key value pair that has the closest center as key and the point itself as value

To perform a sample run, we need some data. We can create is very easily from the R prompt:

```
clustdata = lapply(1:100, function(i) keyval(i, c(rnorm(1, mean = i%%3, sd = 0.01), rnorm(1, mean = i%%4, sd = 0.01))))
rhwrite(clustdata, "/tmp/clustdata")
```

That is, create some arbitrary data in the form of a list of key value pairs, the key here doesn't really matter and write it out to hdfs.
And this is a simple test of what we've just implemented, 

```
rhkmeans ("/tmp/clustdata", 12)
```

Or for short:

```
rhkmeans(
    rhwrite(
	    lapply(1:100, 
               function(i) keyval(i, 
			                      c(rnorm(1, mean = i%%3, sd = 0.01), 
								    rnorm(1, mean = i%%4, sd = 0.01))))), 12)
```

With a little extra work you can even get pretty visualizations like this one (code in source under `tests`

[[kmeans.gif]]

## Linear Least Squares

X√ü = y




solve(t(X)%*%X, t(X)%*%y)




   key1 key2        val

1     1    1  0.7595035

2     1    2  1.1731512

3     1    3  0.2112339

4     2    1  0.2305024

5     2    2 -0.5277821

6     2    3 -2.4413680

7     3    1 -0.8510856




swap = function(x) list(x[[2]], x[[1]])

transposeMap = mkMap(swap, identity)




rhTranspose = function(input, output = NULL){

  revoMapReduce(input = input, output = output, map = transposeMap)

}













We are going to build another example, LLS, that illustrates how to build map reduce reusable  abstractions and how to combine them to solve a larger task. We want to solve LLS under the assumption that we have too many data points to fit in memory but not such a huge number of variables that we need to implement the whole process as map reduce job. This is sort of a hybrid solution that is made particularly easy by the seamless integration of revoHStream with R and an example of a pragmatic approach to big data. If we have operations A, B, and C in a cascade and the data sizes decrease at each step and we have already an in-memory solution to it, than we might get away by replacing only the first step with a big data solution and then continuing with tried and true function and pacakges. To make this as easy as possible, we need the in memory and big data worlds to integrate easily if not seamlessly. 




This is the basic equation we want to solve in the least square sense and we are going to do it by




using the function solve as in this expression, that is solving the normal equations. But now X is too big to fit in memory, so we have to compute the transpose and matrix products using map reduce, then we can do the solve as usual on the results. This is our general plan.




We are going to adopt the following representation for matrices, here in data frame form (behind the scenes it's still lists). The key is the pair row, col and the value is the matrix element. In practice this representation makes sense only for sparse matrices, so in a real world implementation we might want to use a representation with a submatrix for each record, but this is  simpler to develop the ideas.




We start implementing the transpose with a tiny auxiliary function that swaps the elements of a two element list. You guessed right that this is going to be used to swap the raw index with the column index.




Then we define the map function for the transpose map reduce job. It uses a higher order function, mkMap, to turn two ordinary functions into a map. This is possible because they act independently on the key and on the value. What this says is: swap the elements of the key and let the value through. We could have written it just as easily without mkMap, but once you are familiar with it it is more readable this way.




Then we have the map reduce transpose job which is abstracted into a function rhTranspose, that we can use like any other job from now on. It takes an input, an optional output and 




returns the return value of the map reduce job. It passes input and output to it and the map function we've just defined and that's it for transpose.

detour: Relational Joins

A = BC     aij = ‚àëk bik ckj




rhRelationalJoin = function(

  leftinput = NULL,

  rightinput = NULL,

  input = NULL,

  output = NULL,

  leftouter = F,

  rightouter = F,

  fullouter = F,

  map.left= mkMap(identity),

  map.right= mkMap(identity),

  reduce = function (k, vl, vr) keyval(k, list(left=vl, right=vr)))

Now we would like to tackle matrix multiplication but we need a short detour first. This takes one step further in hadoop mastery as we need to combine and process two files into one map reduce job. By default revoMapReduce supports merging two inputs the way hadoop does, that is once can specify multiple inputs and the only guarantee is that every record will go through one mapper. No order or grouping of  any sort is guaranteed as the mappers are processing the input files.




What we need here is a very orderly merging so that we can multiply matrix elements that share an index and then sum them together. It actually looks like a join on one specific index. It turns out that joins are a very important subtask in many map reduce algorithms and are more or less supported in a number of hadoop dialects. A generalized join is implemented in one of the examples packaged with RevoHStream and  as soon as it's ready for prime time we'll move it to the library. Here is how to use ir.




Instead of a single input, we have a left input and right input, as joins normally do, but in case we want to perform a self join, we can skip the first two arguments and 




specify only the third, input.




Then we have an output, optional as usual and 




we can specify different flavors of join such as in left outer, right outer or full outer as usual.




Now to the interesting bits. This function is a bit relational join and a bit map reduce job. Instead of specifying join keys, we specify two separate map functions, one for the left input and one for the right input. Map functions, as usual, produce a key and a value. The join will be an equijoin on the keys. For each pair of matching records there will be a shared key and two values, one coming from the left side. By default, we have simple pass-throguh or identity mappers.




The reduce function has three arguments, one key and two values, one coming from the left input through map.left and the other from the right input through map.right. The default is just to pass the key through and to assemble the two values into a compound value, the closest we could get to a pass-through reducer.




This is a little advanced in a number of way  and also very reusable, so that it's a given this will be part of the library very soon. It has the general flavor of the composable map reduce job, but has two inputs and two maps and the reduce has a non-standard signature. The implementation also has some technicalities related to identifying left and right input, path normalization and stuff that won't make this a newbie map reduce job, even if a basic implementation is all of 60 lines. So the bad news is that I am not going to show the implementation of this, the good news is that it will become a powerful addition to the library so that you don't have to deal with this. Pretty much when you need to combine two different data sets together you can recast it as a join and reuse this function. There are many examples of this and one is matrix multiplication, so back on track.




Linear Least Squares

matMulMap = function(i) function(k,v) keyval(k[[i]], list(pos = k, elem = v))




rhMatMult = function(left, right, result = NULL) {

  revoMapReduce(

                input =

                rhRelationalJoin(leftinput = left, 

                                 rightinput = right,

                                 map.left = matMulMap(2),

                                 map.right = matMulMap(1), 

                                 reduce = 

                            function(k, vl, vr) keyval(c(vl$pos[[1]],                                

                                      vr$pos[[2]]),vl$elem*vr$elem)),

                 output = result,

                 reduce = mkReduce(identity,      

                                   function(x) sum(unlist(x))))}




Back to our matrix multiplication task, that we will implement as a specialization of the general join just shown.




We first define the map function. It comes in two flavor, wether you want to join on the column index or on the row index, and in a matrix multiplication  we need both. So here is a higher order function that generates both maps. It just produces a key-value pair with as key the desired index and as value a list with all the information, row, column and element, which we will need later on.




And finally to the actual matrix multiplication. It is implemented as the composition of two jobs. One does the multiplications and the other the sums. There are other ways of implementing it but this is the most straightforward.




So the first step is a join on the the column index for the left side  and the row index from the right side, so that we bring together element of the  form  bik ckj. In the reduce we perform the multiplication and return a record with a key of i,j and a value equal to the multiplication. 




The following or outer map reduce doesn't have an explicit map, that means it defaults to the pass-through one. The interesting thing is that, by default, the grouping will happen on the (i,j) pair, therefore grouping all the right products that need to be summed together.







Linear Least Squares


to.matrix = function(df) as.matrix(sparseMatrix(i=df$key1, j=df$key2, x=df$val))




rhLinearLeastSquares = function(X,y) {
Xt = rhTranspose(X)
XtX = rhread(rhMatMult(Xt, X), todataframe = TRUE)
Xty = rhread(rhMatMult(Xt, y), todataframe = TRUE) solve(to.matrix(XtX),to.matrix(Xty))}

We now have all the elements in place to solve our LLS: map reduce transpose and matrix multiplication and old fashioned solve()




Well we need a little function to turn matrices represented in list form and sparse format, that we use with map reduce, into regular dense in memory R matrices. We rely on a feature of rhread that turns lists into data frames whenever possible so that this function just has to go from dataframe to dense matrix, using the Matrix package and sparse matrix in particular




Then our sought after semi-big-data LLS solution




Start with a transpose




compute the normal equations left and right side




and call solve on the converted data.







What we have learned

revoMapReduce(map = function(k,v)..., reduce = function(k,vv)...)

revoMapReduce(revoMapReduce(...

revoMapReduce(output = "my-result-file")

my.result = revoMapReduce(...)

my.job = function(x,y,z) { .... out = revoMapreduce(...);  ... out}

out1 = my.job1(my.result); out2 = my.job2(my.result); merge.job(out1, out2)

if(length(rhread(my.job()))¬ª0){...} else {...}; ggplot2(rhread(my.job(...)), ...)

specify jobs using regular r functions and 




run them like R functions




compose jobs like functions




store results where you want




or in a variable




create abstractions




describe any data flow




move things in an out of memory and HDFS to create hybrid big-small-data algorithms, control flow and iteration, display results etc

