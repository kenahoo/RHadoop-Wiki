###Overview
This R package provides basic connectivity to HBASE, using the [Thrift server](http://thrift.apache.org/). R programmers can browse, read, write, and modify tables stored in HBASE. The following functions are part of this package

* Table Maninpulation <br>
        hb.new.table, hb.delete.table, hb.describe.table, hb.set.table.mode, hb.regions.table
* Read/Write <br>
        hb.insert, hb.get, hb.delete, hb.insert.data.frame, hb.get.data.frame, hb.scan
* Utility <br>
        hb.list.tables
* Initialization <br>
        hb.defaults, hb.init

###Prerequisites
* Installing the package requires that you first [install and build Thrift](http://wiki.apache.org/thrift/ThriftInstallation).  Once you have the libraries built, be sure they are in a path where the R client can find them  (i.e. /usr/lib)
* Also, the rhbase package defaults to looking for a Thrift server on localhost port 9090.  If you are running on a  different port you will have to change how the package is initialized

    `hb.init(host=127.0.0.1, port=9090)`
