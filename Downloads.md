### Download Latest Official RHadoop Releases

<font size=4><b>[rmr - 1.3.1](https://github.com/downloads/RevolutionAnalytics/RHadoop/rmr_1.3.1.tar.gz)</b></font><br>
<font size=4><b>[rhdfs - 1.0.5](https://github.com/downloads/RevolutionAnalytics/RHadoop/rhdfs_1.0.5.tar.gz)</b></font><br>
<font size=4><b>[rhbase - 1.0.4](https://github.com/downloads/RevolutionAnalytics/RHadoop/rhbase_1.0.4.tar.gz)</b></font><br>

###Prerequisites

* Hadoop 
    * A working Hadoop cluster is required
    * All three packages were developed and tested on CDH3/CDH4 standalone, and CDH3/CDH4 distributed  
    * For rmr, see [[rmr]]. Otherwise, make sure that the environment variables HADOOP_CMD and HADOOP_STREAMING are properly set.
    Examples:
    <pre>
      HADOOP_CMD=/usr/bin/hadoop
      HADOOP_STREAMING=/usr/lib/hadoop/contrib/streaming/hadoop-streaming-<version>.jar
    </pre>

* R 
    * For the 'rhdfs' and 'rhbase' packages,  we recommend you install R on a data node in the Hadoop cluster.  
    * For the 'rmr' package, install R on each task node in the Hadoop cluster. 
    * All three packages were tested with R 2.15.0. For rmr see [Compatibility](https://github.com/RevolutionAnalytics/RHadoop/blob/master/rmr/pkg/docs/compatibility.md) and [[Which Hadoop for rmr]]

* Package Dependencies
    * The 'rhdfs' package is dependent on the pakage rJava.  
    * The 'rmr' package is dependent on the packages Rcpp, RJSONIO, itertools and digest

* Library Dependencies
    * The 'rhbase' package requires the Thrift library. For more information, refer to the wiki page [[rhbase]] 

###Installation
1.     Download each R package
1.     Enter the command:  <b>R CMD INSTALL 'package filename'</b>
1.     Load the package in the R console 
Important:  The 'rmr' package must be installed on each node of the Hadoop cluster.

Contact: rhadoop@revolutionanalytics.com