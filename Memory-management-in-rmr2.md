Users that have deployed rmr2 in production have raised the issue of controlling the amount of memory used by by R while running as a mapper or reducer on the nodes of a cluster. After reviewing some exchanges among Rhipe users and devs and on a Cloudera user forum, we can recommend the following approach, which is based on setting a number of properties in the `hadoop-site.xml` file.
First pair is controlling the amount of memory allocated to Java (for map or reduce)

```
<property> 
  <name>mapred.map.child.java.opts</name> 
  <value>-Xmx2000m</value> 
</property> 
<property> 
  <name>mapred.reduce.child.java.opts</name> 
  <value>-Xmx2000m</value> 
</property> 
```
Here set to 2G for both. I am not endorsing a specific setting, only showing how to change them.
Then we have a pair controlling the memory limits at the unix level (ulimit)

```
<property> 
  <name>mapred.map.child.ulimit</name> 
  <value>1126400</value> 
  <final>true</final> 
</property> 
<property> 
  <name>mapred.reduce.child.ulimit</name> 
  <value>1126400</value> 
  <final>true</final> 
</property> 
```

These should take into account both the java process and the R process. That is subtract what was set in the previous pair of properties and what is left is what R has available.

Finally since setting limits does not increase the amount of memory available, you may want to run fewer concurrent map and reduce tasks on each node.

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

1 being the lowest possible setting, but not the only one to consider. This looks helpful for a cluster that has one type of load, but in the presence of a mixed load of high mem and low mem jobs I think the capacity scheduler is the way to go and we will try to support it as soon as it is more widely available.