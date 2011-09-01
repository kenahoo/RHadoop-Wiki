#Efficient rmr techniques

We will try to collect here different observations, guidelines and examples about writing efficient and scalable programs with rmr. These observations are related to the mapreduce programming model, its specific implementation in hadoop and R as a programming language. 

## Mapreduce
Considering here the abstract programming model, not the implementation specifics, the level of available parallelism in the map phase is as high as the number of input records. Each record can be, in principle, processed independently and therefore in parallel. No so in the reduce phase. The maximum level of parallelism is determined by the cardinality of the set of keys. A single reducer has to process all the records associated with one key. This has the potential to negate the scalability of mapreduce. This may come as a suprise as it is often, incorrectly said that, once a computation is recast as a mapreduce computation, parallelism and scalability are ensured. While there aren't general solution to this problem, there are some techniques that can help.
 
 * a
 * a
 * a
