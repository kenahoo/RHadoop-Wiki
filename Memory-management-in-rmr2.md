Users that have deployed rmr2 in production have raised the issue of controlling the amount of memory used by by R while running as a mapper or reducer on the nodes of a cluster. After reviewing some exchanges among Rhipe users and devs and on a Cloudera user forum, we can suggest the approach described below. 

## The problem

The hadoop scheduler before YARN, which is not recommended for production yet, schedules a maximum number of map tasks and reduce tasks per node. If they use memory in an unconstrained fashion, hardware resources may be exceeded resulting in run-time errors. These errors are particularly worrisome for two reasons: 
* they can be hard to reproduce as they depend on the load on a specific cluster node at the time of execution
* the process that failed is not necessarily the one to blame, and it may be hard to actually assign the blame even having a complete list of processes running on a node.

A solution often recommended is to limit each process to use an amount of memory such that each node has enough memory to run the maximum allowed number of map and reduce tasks. It doesn't ensure great utilization but it makes Out of Memory failures again "local" that is whenever one occurs the culprit is the process that failed.

There is an additional twist when running streaming jobs, which is how rmr2 jobs are implemented. Unlike a pure Java mapreduce job, here there are two processes running: one is hadoop streaming and the other is the mapper or reducer. In the case of rmr2, that's an instance of the R interpreter. So simply bounding the amount of memory used by a JVM instance is not enough, we need to ensure that the R interpreter stays within predetermined bounds.


## One solution
The approach described here consists of setting a number of properties in the `hadoop-site.xml` file.
First pair of properties is controlling the amount of memory allocated to the JVM (for map or reduce)

```
<property> 
  <name>mapred.map.child.java.opts</name> 
  <value>-Xmx1000m</value> 
</property> 
<property> 
  <name>mapred.reduce.child.java.opts</name> 
  <value>-Xmx1000m</value> 
</property> 
```

Here they are set to 1G for both; I suspect for streaming, where most of the work is done in R, this could be lower. We will try to suggest some specific settings in the future.

Then we have a pair controlling the memory limits at the unix level (ulimit):

```
<property> 
  <name>mapred.map.child.ulimit</name> 
  <value>2097152</value> 
  <final>true</final> 
</property> 
<property> 
  <name>mapred.reduce.child.ulimit</name> 
  <value>2097152</value> 
  <final>true</final> 
</property> 
```

The values are in KBs. In CDH4 and other recent distros you may want to use the shorter version which drops the "child" part from the name. These should take into account both the java process and the R process. That is subtract what was set in the previous pair of properties and what is left is what R has available. In the above examples R has 1G available.

Finally since setting limits does not increase the amount of memory available in hardware, you may want to run fewer concurrent map and reduce tasks on each node.

```
<property> 
  <name>mapred.tasktracker.map.tasks.maximum</name> 
  <value>1</value> 
  <final>true</final> 
</property> 
<property> 
  <name>mapred.tasktracker.reduce.tasks.maximum</name> 
  <value>1</value> 
  <final>true</final> 
</property> 
```

1 being the lowest possible setting, but not the only one to consider. 

If you don't have access to the configuration files or don't want to change them because the settings are not appropriate for every job, you can set them on job-by-job basis with the `backend.parameter` option to `mapreduce`. The above settings would look like:

```
backend.parameters = 
  list(
    hadoop = 
      list(
        D = "mapred.map.child.ulimit=2097152",
        D = "mapred.reduce.child.ulimit=2097152",
        D = "mapred.tasktracker.map.tasks.maximum=1",
        D = "mapred.tasktracker.reduce.tasks.maximum=1))
```

Again that `1` will have to be raised to something like 0.95 of available reduce slots in your cluster.

## The future
I think for better utilization with mixed loads the [capacity scheduler](https://hadoop.apache.org/docs/stable/capacity_scheduler.html) is very promising. 