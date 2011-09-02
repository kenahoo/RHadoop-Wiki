# Efficient rmr techniques

We will try to collect here different observations, guidelines and examples about writing efficient and scalable programs with rmr. These observations are related to the mapreduce programming model, its specific implementation in hadoop and R as a programming language. 

## Mapreduce

Considering here the abstract programming model, not the implementation specifics, the level of available parallelism in the map phase is as
high as the number of input records. Each record can be, in principle, processed independently and therefore in parallel. No so in the
reduce phase. The maximum level of parallelism is determined by the cardinality of the set of keys. A single reducer has to process all the
records associated with one key. This has the potential to negate the scalability of mapreduce. This may come as a suprise as it is often,
incorrectly said that, once a computation is recast as a mapreduce computation, parallelism and scalability are ensured. While there aren't
general solution to this problem, there are some known techniques that can help.

In the classic word count example, the risk is that one procesor has to got through all the occurrences of a single word, even the most
common. This can be a problem both from a worst case analysis point of view and in real word text analysis. One can offer three different
approaches
* Sampling. One can run a sampling job, sampling at a fixed rate, to get an estimate of the word frequencies, then run a second job sampling
  at a rate inversely proportional to the initial estimate to get better esitmates for the low frequency words without incurring in
  bottlenecks.
* Break a task into multiple jobs. The above can already be seen as an example of running two scalable jobs instead of a non-scalable one,
  but it involves an approximation. If that is not acceptable, one can still find a scalable multiple job solution to the wordcount problem
  by generating keys that are a combination of the word to be counted and a random integer between one and the ideal number of
  reducers. That way even the most common word occurrences get split over all processors. In a second job these partial counts are
  accumulated word by word.
* Combiners. This case is so common that it has been baked into hadoop as a special feature. Whenever the reduce represents an operation on
  the records for each key that is associative and commutative, one can apply the reduce function on arbitrary subsets and again on the
  results thereof. Examples are counting as above or max and min or averaging, if we espress the average as a (total, count) pair and even
  the median if we accept that the median of medians is a good enough approximation. This prelimary reduce application can be triggered
  simply specifying that we want a combiner. Since the combiner is run right after the map, on the same node, as opposed to the multiple job
  solution, the cost of the shuffling phase is often drastically reduced. The combiner can be in principle a function different from the
  reducer, but since there isn't a guarantee that the combiner will be actually applied to each record, I have yet to see an example of
  nontrivially different combiner and reducer.

## Hadoop

* Hadoop implements the mapreduce model on top of HDFS (next generation Hadoop actually generalizes over this). That means that there are
  phases of disk and network I/O that are integral to the computation, before and after each map and reduce phase. It's not that I/O is a
  new concept: the new idea is that it is integral to this type of very large computations and not limited to an initial and final phase,
  somewhat separate from the actual computation, as in the single machine, in RAM kind of computation we are all familiar with (see also
  NUMA systems). To be more concrete, in designing algorithms for hadoop we may face tradeoffs between the total amount of CPU work and the
  number of jobs involvesd. Since adding a job means adding a I/O intensive phase, it may be worth reducing the number of jobs even if each
  job is going to perform more CPU-work. This is an apparent contradiction with the suggestion to break a task into multiple jobs offered
  above, but there are tradeoffs between I/O costs, degree of parallelism, total CPU work that can play out differently for different
  problems and solutions. Fast, scalable, efficient, pick 2; more realistically, find the right compromise. For instance, in the tutorial we
  implemented logistic regression by gradient descent. Given that each step is a separate mapreduce job and that gradient descent is known
  to have slower convergence than other methods, it is natural to consider methods with faster convergence such as conjugate gradient, even
  if each iteration requires more work.
* Hadoop has a very complex configuration that may need to be optimizes for rmr jobs, either per job or on a global basis. For instance, we
  observed rmr jobs to be mostly CPU bound (see following point). Therefore the optimal number of concurrent tasks on each node could be as
  low as the number of cores. For I/O bound processes, this number has been set as high as 300.

## R

It is well known that the R interpreter is no speed daemon. Actually more like 50X to 100X C code, and I mean time. So what to do about it?

* Nothing. It doesn't matter. Somebody has said that most widespread, useful algorithms take time linear in the size of the input, linear
  programming notwihtstanding, so the limiting factor is anyway I/O. This argument is great on paper, but in my limited experiments doesn't
  apply to rmr. Since hadoop takes great pain to optimize I/O minimizing disk seeks, in limited experiments conducted so far jobs were
  always CPU-limited.
* Use the compiler. While this is a promising technology that is now distributed with the main R distribution, the promised speed gains
  apply only to a subset of the language. rmr itself is not compiled yet but it will. The work on the compiler is active and improvements
  are expected this year. Expect something like 4X speedups as the compiler matures.
* Write in C or leverage the work of people who did. R has a remarkably convenient interface to calling C functions and many library
  functions are written that way. For this approach to make a dent in the overall computing time we need most of the time to be spent
  outside the interpreter executing optimized C code. To achieve that, any invocation to C-implemented functions from R has to get a
  signficant chunk of work done to offset the function call overhead. A programming style for rmr that makes this more feasible is one where
  each input record is bigger than what is typical in the tutorial. This is an efficient style for hadoop in general. For instance, instead
  of a single matrix element, one could store a submatrix in each record. In machine learning, one could store a subset of training data
  points instead of one. By doing this, one can reduce the number of records and thus the number of calls to the map and reduce
  functions. Then it becomes a matter of implementing that function efficiently by using efficient liberary calls or writing the function in
  C.

## rmr

In the first part of this project, we focsued on, as they say, "getting the API right", that is trying to achieve a seamless integration of
mapreduce into R trying to make rmr interoperate and combine with other R features and language constructs, making rmr programs as readable
as possible, minimize any "surprise factor" etc. We have not focused on efficiency but we expect that to change as we gather feedback from
the community. Here are some related activities and improvements that could make it to the roadmap:

* Performance testing. Testing at scale has been very limited and a new profiling feature has not been put to much use yet. We recommend
  that people turn on profiling of the nodes during development and share their observations. We would be interested in taking a look at the
  results and helping with either code optimizations or, where warranted, optimizations in rmr itself.
* Binary formats. Right now the default format is based on JSON (two JSON objects per line separated by a tab, for streaming
  compatibility). This is great for learning and debugging and also for interoperability with other data source (after all, we expect rmr to
  work mostly from non-rmr sources for the foreseeable future, , see for instance AVRO-808 for the different possibilities). We convert to a
  and from JSON using RJSONIO, which has been optimized for large object conversion (read, written partly in C). There are different
  opinions out here as whether streaming can be used with binary formats (see
  [this blog entry](http://mail-archives.apache.org/mod_mbox/avro-user/201004.mbox/%3C20100422031942.GB28156@kiwi.sharlinx.com%3E) and
  AVRO-512) but I think HADOOP-1722 settles the question in the positive. Dumbo, a streaming-based library for python, has access to AVRO
  files through some Java class that performs the conversion
  (http://www.tomslabs.com/index.php/2011/06/use-avro-with-dumbo-for-hadoop-jobs/) and can use
  [binary formats](http://dumbotics.com/2009/02/24/hadoop-1722-and-typed-bytes/). An alternative R library for map reduce, RHIPE, uses
  Google's Protocol Buffers as the preferred data format, but doesn't use hadoop streaming to the best of my understanding.
* Configuration. We have resisted adding options to fine tune the workings of map reduce on a per-job basis -- things like number of
  mappers, number of reducers, number of concurrent tasks etc. -- for a number of reasons:
  * to keep the API simple and clean
  * because it is not very compatible with having multiple backends (in rmr dev there is the option of an R-only backend for debugging)
  * because of general recommendations against it by API gurus ("All tuning parameters are suspect" -- Josh Bloch)
  * in the hope that hadoop will mature to a point where configuration issues will become less of a concern.
  
  A principled compromise on this issue may be necessary to achieve the full potential of rmr.
* Compiler: the R compiler has been brewing for reportedly 10 years and doesn't optimize function calls, but there is no reason not to try it out. 
