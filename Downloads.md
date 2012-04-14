### Download Latest Official RHadoop Releases

<font size=4><b>[rmr - 1.2](https://github.com/downloads/RevolutionAnalytics/RHadoop/rmr_1.2.tar.gz)</b></font><br>
<font size=4><b>[rhdfs - 1.0.2](https://github.com/downloads/RevolutionAnalytics/RHadoop/rhdfs_1.0.2.tar.gz)</b></font><br>
<font size=4><b>[rhbase - 1.0.4](https://github.com/downloads/RevolutionAnalytics/RHadoop/rhbase_1.0.4.tar.gz)</b></font><br>

###Prerequisites

* Hadoop 
    * A working Hadoop cluster is required
    * All there packages were developed and tested on CDH3 standalone, and CDH3 distributed  
    * Make sure that the environment variables HADOOP_HOME and HADOOP_CONF are properly set.
    Examples:
    <pre>
      HADOOP_HOME=/usr/lib/hadoop
      HADOOP_CONF=/etc/hadoop/conf
    </pre>

* R 
    * For the 'rhdfs' and 'rhbase' packages,  we recommend you install R on a data node in the Hadoop cluster.  
    * For the 'rmr' package, install R on each task node in the Hadoop cluster. 
    *  All three packages were tested with R 2.13.1

* Package Dependencies
    * The 'rhdfs' package is dependent on the pakage rJava.  
    * The 'rmr' package is dependent on the packages RJSONIO, itertools and digest

* Library Dependencies
    * The 'rhbase' package requires the Thrift library. For more information, refer to the wiki page [[rhbase]] 

###Installation
1.     Download each R package
1.     Enter the command:  <b>R CMD INSTALL 'package filename'</b>
1.     Load the package in the R console 
Important:  The 'rmr' package must be installed on each node of the Hadoop cluster.

Contact: rhadoop@revolutionanalytics.com
