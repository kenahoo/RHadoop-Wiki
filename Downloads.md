### Official release of the RHadoop packages  (built from the "master" branch)
The current version of the packages is 1.0

* [rmr - 1.0](https://s3.amazonaws.com/rhadoop/master/rmr_1.0.tar.gz)
* [rhdfs - 1.0](https://s3.amazonaws.com/rhadoop/master/rhdfs_1.0.tar.gz)
* [rhbase - 1.0](https://s3.amazonaws.com/rhadoop/master/rhbase_1.0.tar.gz)

###Installation and Prerequisites

•Haddop - A working Hadoop cluster (this package was developed and tested on CDH3 standalone, and CDH3 distributed).  Make sure that the environment variables HADOOP_HOME and HADOOP_CONF are properly set.
Examples:
<pre>
  HADOOP_HOME=/usr/lib/hadoop  
  HADOOP_CONF=/etc/hadoop/conf
</pre>

•R - For 'rhdfs' and 'rhbase',  R client typically installed on the 'name' node of the Hadoop Cluster.  For 'rmr', R installed on each node in the Hadoop cluster. (packages tested with R 2.13.1)

•Dependent Packages - 'rhdfs' depends on rJava.  'rmr' depends on RSJSONIO, itertools and digest

•Dependent Libraries - 'rhbase' use Thrift (see the wiki page [[rhbase]] for more details).

Packages should be installed from the command line using:  <b>R CMD INSTALL 'package filename'</b>  Note:  'rmr' needs to be installed on each node of the Hadoop Cluster.



### Experimental Development builds of the RHadoop packages (built from the "dev" branch)

* [rmr - dev](https://s3.amazonaws.com/rhadoop/dev/rmr_1.0.tar.gz )
* [rhdfs - dev](https://s3.amazonaws.com/rhadoop/dev/rhdfs_1.0.tar.gz  )
* [rhbase - dev](https://s3.amazonaws.com/rhadoop/dev/rhbase_1.0.tar.gz  )
