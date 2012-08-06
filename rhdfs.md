###Overview
This R package provides basic connectivity to the Hadoop Distributed File System. R programmers can browse, read, write, and modify files stored in HDFS. The following functions are part of this package

* File Manipulations <br> 
        hdfs.copy, hdfs.move, hdfs.rename, hdfs.delete, hdfs.rm, hdfs.del, hdfs.chown, hdfs.put, hdfs.get
* File Read/Write <br>
        hdfs.file, hdfs.write, hdfs.close, hdfs.flush, hdfs.read, hdfs.seek, hdfs.tell, hdfs.line.reader, hdfs.read.text.file
* Directory <br> 
        hdfs.dircreate, hdfs.mkdir
* Utility <br> 
        hdfs.ls, hdfs.list.files, hdfs.file.info, hdfs.exists
* Initialization <br> 
        hdfs.init, hdfs.defaults

###Prerequisites
* This package has a dependency on rJava
* Access to HDFS via this R package is dependent upon the `HADOOP_CMD` environment variable. `HADOOP_CMD` points to the full path for the `hadoop` binary.  If this variable is not properly set, the package will fail when the `init()` function is invoked

Example:

    HADOOP_CMD=/usr/bin/hadoop  

###R Objects
R objects can be serialized to HDFS via the function: `hdfs.write`.  An example is shown below:

    model <- lm(...)
    modelfilename <- "my_smart_unique_name"
    modelfile <- hdfs.file(modelfilename, "w")
    hdfs.write(model, modelfile)
    hdfs.close(modelfile)

R objects can be deserialized to HDFS via the function: `hdfs.read`.  An example is shown below:

    modelfile = hdfs.file(modelfilename, "r")
    m <- hdfs.read(modelfile)
    model <- unserialize(m)
    hdfs.close(modelfile)