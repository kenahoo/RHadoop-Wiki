###Overview
This R package allows an R programmer to perform statistical analysis via MapReduce on a Hadoop cluster. 

###Prerequisites
* A Hadoop cluster (this package was developed and tested on CDH3 standalone, and CDH3 distributed)
* R installed on each node of the cluster (developed and tested on 2.13.0) 
* Install the following dependent R packages on each node: rjson, itertools and digest
* rmr itself needs to be installed on each node.
* Make sure that the environment variables `HADOOP_HOME` and `HADOOP_CONF` are properly set.
  
Examples:

      HADOOP_HOME=/usr/lib/hadoop  
      HADOOP_CONF=/etc/hadoop/conf


###[[Philosophy]]
###[[Tutorial]]
###[[Writing composable mapreduce jobs]] 

