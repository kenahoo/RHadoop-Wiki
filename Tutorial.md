
Map Reduce in R

with Revolution RevoHStream

My first map-reduce job

    small.ints = 1:10
    out = lapply(small.ints, function(x) x^2)

    small.ints = rhwrite(1:10)
    out = revoMapReduce(input = small.ints, map = function(k,v) keyval(k^2))
    rhread(out)




revoMapReduce(input = out, ...)




(reveal more code on empty lines)

We start by showing how using RevoHStream, is, at its simplest level, not much different from writing a lapply.




Here you are seeing the simplest of lapplys, computing the first 10 squares. 

Now you want to do this in map reduce. You need to get your data onto HDFS, because that's the data storage behind hadoop map reduce.




It takes just this one line. Of course this works because 1:10 fits in memory, which by definition won't be the case for big data, but rhwrite is great to generate test data and other support uses.




Then the main call, which replaces lapply with revoMapReduce and it's better to name the arguments because the interface is a bit more complicated than lapply when you are using it to the full power, but defaults are helpful. Another difference is that the map function takes a key and a value a returns a pair, returned by the keyval function. In this case we are using only the key, but the general case needs both. So we have small differences but the complexity is about the same, and you have access to the power of hadoop.




The return value is an object, actually a closure, and you can pass it as input to other jobs or read it into memory (watch out, not good for big data) with rhread. Rhread is the dual of rhwrite. It returns a list of key value pairs, which is the most general data type that mapreduce can handle. If you prefer data frames to lists, we are working on a simplified interface that accepts and returns data frames instead of lists of pairs, which will cover many  many important use cases. rhread is useful in defining practical map reduce algorithms whenever a map reduce jobs produces something of reasonable size, like a summary, that can fit in memory and needs to be inspected to decide on the next steps, or to visualize it.

My second map-reduce job




groups = rbinom(32, n = 50, prob = 0.4)

tapply(groups, groups, length)




groups = rhwrite(groups)

revoMapReduce(input = groups, 

    reduce = function(k,vv) keyval(k, length(vv)))

We've just created a simple job that was logically equivalent to a lapply but can run on big data. That job had only a map. Now to the reduce part. The closest equivalent in R I think is a tapply. So here is the example in the R docs







This creates a sample from the binomial and counts how many times each outcome occurred. Now to the map-reduce or big data equivalent.




First we put the same data in hdfs. Of course this is not the normal way in which data will enter hdfs, it will be by some scalable data collecting system such as scribe or flume, or from traditional DBs using scoop or what have you.




And here is our map reduce job. There isn't any map, so the default kicks in which is an identity function.

The reduce function has one key and a list of values as arguments and returns a keyval or list thereof. In this case, the key is the outcome of the binomial and the values are nulls and the only important thing is how many there are, which is what length does.




Looking back, yes we took a little hit in complexity but the analogy between the two is very close. 

Wordcount

rhwordcount = function(input, output = NULL, pattern = " ") {

  revoMapReduce(input = input ,

                output = output,

                textinputformat = rawtextinputformat,

                map = 

                  function(k,v) {

                    lapply(

                      strsplit(

                      x = v,

                      split = pattern)[[1]],

                    function(w) keyval(w,1))},

                reduce = function(k,vv) {

                  keyval(k, sum(unlist(vv)))},

                combine = T)}

(empty lines inserted where new lines need to appear)




I am going to show how easy it is to write the "hello world" equivalent for map reduce.

 

We are going to define one function that encapsulates this job. This may not look like a big deal but it is. We want to make MR jobs first class citizen of the R environment and we want to be able to create abstractions based on them. We take the first step here by creating a function that is itself a job, can be chained with other jobs, executed in a loop etc. Let's now look at the signature. There is an input, an output and an optional pattern. We can think of input and output as hdfs paths, even if there are other possibilities. Pattern defines what the definition of word is for the user.




To accomplish this, we just need one call to the central API function, RevoMapReduce. 




We just pass along input and output.




We need to specify a parser for the input. The default is a JSON-based format that can cover many different use cases. In this case we just want to read a text file, so we specify this text reader.




The map function take two arguments, a key and a value. The key here is not important. The value contains one line of text




that gets split according to a pattern. Here you can see that pattern is accessible in the mapper without any particular work on the programmer side and according to normal R scoping rules. In fact this is no different or harder than writing a lapply - tapply combination for the same task.




for each word we create a pair (word, 1) that gets wrapped into a helper function, keyval. All your mappers need to return a keyval or list thereof,  like in this case.




Then we have a reduce function that takes a key and a list of values as input and  simply sums up all the counts and returns the pair word, count using the same helper function, keyval

Logistic Regression

rhLogisticRegression = function(input, iterations, dims, alpha){

  plane = rep(0, dims)

  g = function(z) 1/(1 + exp(-z))

  for (i in 1:iterations) {

    gradient = rhread(revoMapReduce(input,

      map = 

          function(k, v) keyval(1, v$y*v$x*g(-v$y*(plane %*% v$x))),

      reduce = 

          function(k, vv) keyval(k,apply(do.call(rbind,vv),2,sum)),

      combine = T))

    plane = plane + alpha * gradient[[1]]$val }

  plane }

    




Now onto an example from supervised learning, specifically logistic regression by gradient descent.




As you can see we have of course an input with the training data. For simplicity we ask to specify a fixed number of iterations, but it would incrementally more difficult to specify a convergence criterion. Then we need to specify the dimension of the problem, which is a bit redundant because it can be inferred after seeing the first line of input, but we didn't want to put additional logic in the map function so it's a  small compromise and then we have the learning rate alpha.




We start by initializing the separating plane and defining the logistic function. Those identifiers are in bold because they will be used inside the map function, that is they will travel across interpreter and processor and network barriers to be available where the developer needs them and where a traditional, meaning sequential, R developer expects them to be available.




Now to the main loop where computing the gradient of a loss  function is the duty of a map reduce job, whose output is brought straight into main memory with an rhread -- there are temp files being created and destroyed behind the scenes but you don't need to know. The only important thing is that, reasonably, the gradient is going to fit in memory so we can do an rhread to get it with impunity.

This map reduce job as the input we specified in the first place, the training data. 




The map function simply computes the contribution of an individual point to the gradient, Please note the variables g and plane making their necessary appearance here without any work on the developer's part. The access here is read only but you could even modify them if you wanted -- the semantics is copy on assign, which is consistent with how R works and easily supported by hadoop. Since in the next step we just want to add everything together, we emit a dummy, constant key for each record.




The reduce function, besides the usual R fidgeting to get numbers out of lists, is just a big sum. As far as the fidgeting, we decided to support the more general lists first and then add some API convenience for the cases where a data frame would suffice. It's not as general as we would like to be but you can try it  (reduceondataframe = T).




Since we have only one key, all the work will fall on one reducer and that's not scalable, so in this example it's important to activate the combiner, in this case it's TRUE  so it's the same as the reducer. Since sums are associative and commutative that's all we need.




After the map reduce job is complete and rhread has copied the only record that is supposedly produced by this job into the gradient variable, we just have to upgrade the separating plane and return it after the iterations are complete.




To make this example production-level there are several things one needs to do, like having a convergence criterion instead of a fixed iteration number an an adaptive learning rate,  but probably gradient descent just requires too many iterations to be the right approach in a big data context. But this example should give you all the elements to be able to implement conjugate gradient instead. In general, when each iteration requires I/O of the whole or largest share of the data set, the number of iterations needs to be contained and algorithms with O(log(N)) number of iterations are natural candidates, even if the work in each iteration may be more substantial.




K-means

rhkmeans =

  function(points, ncenters, iterations = 10, 

           distfun = 

             function(a,b) norm(as.matrix(a-b), type = 'F')) {

    newCenters = rhkmeansiter(points, distfun = distfun, 

                       ncenters = ncenters)

    for(i in 1:iterations) {

      newCenters = lapply(getValues(newCenters), unlist)

      newCenters = rhkmeansiter(points, distfun, centers=newCenters)}

    newCenters

  }







We are now going to cover a simple but significant clustering algorithm and the complexity will go up just a little bit

We are talking about k-means and we are going to implement it in two parts: a function that controls the iterations and termination of the algorithm and one, essentially a mapreduce job, that does the grunt work of computing distances and electing centers. This is not a production ready implementation, but should be illustrative of the power of this package. You simply can not do this in pig or hive and it would take hundreds of lines of code in java.




This is the controlling program. Most of this lines are executed locally. We define a function that  takes a set of points, a desired number of centers, a number of iterations (a convergence test would be better, just for illustration purposes) and a distance function defaulting to euclidean distance.







This function is build on top of another function, rhkmensiter which implements one iteration of kmeans. It can be called in two flavors. In the one shown here, only the number of centers is specified. The function returns  a new set of centers.




Now let's enter the main iteration loop




This line is just turning a list into a matrix and doesn't really do anything interesting. The issue here is that in the general case map reduce jobs can return lists. but data frames or matrices are enough for very common cases such as this one. We are working on changes in the API to better support the common cases as well. So please don't let this line ruin your day.




And this is the other flavor of the main iteration call, where a set of centers rather than just the number of centers is provided. and the return value is, as before, a new set of centers.

K-means

rhkmeansiter =

  function(points, distfun, ncenters = length(centers),

           centers = NULL) {

    rhread(

      revoMapReduce(input = points,

         map = 

            if (is.null(centers)) {

               function(k,v)keyval(sample(1:ncenters,1),v)}

            else {

               function(k,v) {

                 distances = lapply(centers, 

                                  function(c) distfun(c,v))

                 keyval(centers[[which.min(distances)]],v)}},

         reduce = 

             function(k,vv) 

                keyval(NULL, 

                       apply(do.call(rbind, vv), 2, mean))))}







This is one iteration of kmeans, implemented as a map reduce job. We are already familiar with all the paramers to this function




 and we know what rhread does, in this case it moves new cluster centers computed by a mapreduce job and store in hdfs into main memory. Here we are assuming we have a lot of points, as in big data, but a small number of centers, as in they fit in RAM. It's a common case but it might not cover all applications.




And this is the call performing the map reduce job. Its input us a set of points and that tells us that the variable points is just a path to an hdfs file, not a regular variable.




We have two cases  for the map function, one for the first iteration, that is when there isn't a set of current cluster centers, only a number, and one for the rest of the iterations




In the former we just assign a random center to each points and generate a keyval pair with the center as key and the point as value. That means, in the reduce stage, we are guaranteed that all points with the same center will end up together in the same reduce call. Of course that could mean that some reducers have an unacceptable amount of work to perform, but a simple modification of this program and  the use of a combiner fixes that problem, so we are going to ignore it for now (combiners are available in dev)




In the latter we compute all the distances from a point to each center and return a key value pair that has the closest center as key and the point itself as value

K-means

## sample data, 12 clusters

clustdata = lapply(1:100, function(i) keyval(i, c(rnorm(1, mean = i%%3, sd = 0.01), rnorm(1, mean = i%%4, sd = 0.01))))




rhwrite(clustdata, "/tmp/clustdata")

rhkmeans ("/tmp/clustdata", 12)

And this is a simple test of what we've just implemented, 







create some arbitrary data in the form of a list of keyval pairs, the key here doesn't really matter




write it out to hdfs




fire up rhkmeans




with a little extra work you can even get pretty visualizations like this one

Linear Least Squares

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

