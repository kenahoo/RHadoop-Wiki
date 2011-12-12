### Download Latest Official RHadoop Release

* [rmr - 1.1](https://github.com/downloads/RevolutionAnalytics/RHadoop/rmr_1.1.tar.gz)
* [rhdfs - 1.0.1](https://s3.amazonaws.com/rhadoop/master/rhdfs_1.0.1.tar.gz)
* [rhbase - 1.0.1](https://s3.amazonaws.com/rhadoop/master/rhbase_1.0.1.tar.gz)

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
    * For the 'rhdfs' and 'rhbase' packages,  we recommend you install R on the 'name' node of the Hadoop cluster.  
    * For the 'rmr' package, install R on each node in the Hadoop cluster. 
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

### Experimental RHadoop Development builds
The following versions are experimental and built from the ‘dev’ branch

* [rmr - dev](https://s3.amazonaws.com/rhadoop/dev/rmr_1.0.tar.gz )
* [rhdfs - dev](https://s3.amazonaws.com/rhadoop/dev/rhdfs_1.0.tar.gz  )
* [rhbase - dev](https://s3.amazonaws.com/rhadoop/dev/rhbase_1.0.tar.gz  )

Contact: rhadoop@revolutionanalytics.com
