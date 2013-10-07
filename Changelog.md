# Changelog

## rmr 2.3.0

* Supports the upcoming [[plyrmr]] package, now in preview.
* New backend independent file operations 
* New "pig.hive" format to import/export from/to those systems
* Speed improvements when using data frames.
* Better key normalization, prevents occasional grouping errors.
* Limit broadcasting of large objects for efficiency reasons, under user contol.

See [New in this release](https://github.com/RevolutionAnalytics/rmr2/blob/2.3.0/docs/new-in-this-release.md) for details.

## rmr 2.2.2

* Fixes two bugs, one of which can cause occasional, hard to detect data corruption. Recommended upgrade.

See [New in this release](https://github.com/RevolutionAnalytics/rmr2/blob/2.2.2/docs/new-in-this-release.md) for details.


## rhbase 1.2.0

* Adds "character" serialization which inherits the behavior of what was "raw" in the previous release. "raw" is now really raw, meaning database contents are represented as raw vectors, no transformations applied.

## rhdfs 1.0.6

* Compatible with Hortonworks Data Platform for windows.

## rmr 2.2.1

* Compatible with Hortonworks Data Platform for windows.
* Speed improvements
* A number of bug fixes affecting, among others, `equijoin` and the local backend.

See [New in this release](https://github.com/RevolutionAnalytics/rmr2/blob/2.2.1/docs/new-in-this-release.md) for details.

## rmr 2.2.0
* `equijoin` now accepts I/O format specs like `mapreduce`.
* `rmr.options` now give access to a `dfs.tempdir` setting to set the HDFS tempdir to a different setting from the R tempdir. 
* `rmr.str` returns its own argument, which allows less intrusive code changes when adding logging.
* Made some error messages more informative.
* Bugs affecting `c.keyval`, `equijoin`, `keyval`, the CSV input and ouput formats, the "reduce calls" counter and the `backend.parameters` option to `mapreduce`

See [New in this release](https://github.com/RevolutionAnalytics/rmr2/blob/2.2.0/docs/new-in-this-release.md) for details.


## rmr 2.1.0
* Faster, with both behind-the-API work and some additional features focused on accelerating the reduce phase. 
  * Reduce functions can be vectorized w.r.t to the keys, in addition to the values, for the case of small reduce groups. 
  * In-memory combiners can be faster than the regular variety for some applications. 
* Counters provide an additional way to monitor jobs and memory profiling helps with optimization. 
* HBase input format to process directly HBase tables 
* `c.keyval` function that helps creating complex key-value pairs. 

See [New in this release](https://github.com/RevolutionAnalytics/rmr2/blob/2.1.0/docs/new-in-this-release.md) for details.

## rmr 2.0.2
* Lighter dependencies, compatible with R 2.15.2 and numerous bug fixes, many related to `equijoin`.

See [New in this release](http://github.com/RevolutionAnalytics/rmr2/blob/rmr-2.0.2/docs/new-in-this-release.md) for details.

## rmr 2.0.1  
* Tested on CDH3, CDH4, Apache Hadoop 1.0.4 and MapR 2.0.1.
* Many bug fixes including `rmr.sample` and `equijoin`.

See [New in this release](http://github.com/RevolutionAnalytics/rmr2/blob/rmr-2.0.1/docs/new-in-this-release.md) for details.

## rmr 2.0.0  
* Simplified API with better support for vectorization and structured data. As a trade off, some porting of 1.3.1 based code is necessary.
* Modified native format now combines speed and compatibility in a transparent way; backward compatible with 1.3.x
* Completely refactored source code
* Added non-core functions for sampling, size testing, debugging and more
* True map-only jobs

See [New in this release](http://github.com/RevolutionAnalytics/rmr2/blob/rmr-2.0.0/docs/new-in-this-release.md) for details.

## rmr 1.3.1

* Tested on CDH3, CDH4, and Apache Hadoop 1.0.2
* Completed transition of the code-heavy part of the documentation to Rmd

See [New in this release](http://github.com/RevolutionAnalytics/RHadoop/blob/66ca069201d6ed73be548136b06b86361b4f82b3/rmr/pkg/docs/new-in-this-release.md) for details.

## rmr 1.3
* An optional vectorized API for efficient R programming when dealing with small records.
* Fast C implementations for serialization and deserialization from and to typedbytes.
* Other readers and writers work much better in vectorized mode, namely csv and text
* Additional steps to support structured data better, that is you can use more data frames and less lists in the API
* Better whirr scripts, more forgiving behavior for package loading and bug fixes

See [New in this release](http://github.com/RevolutionAnalytics/RHadoop/blob/4efbd435aff3d52cfea116b663100baf637035cc/rmr/pkg/docs/new-in-this-release.md) for details.

## rmr 1.2 
* Binary formats
* Simpler, more powerful I/O format API
* Native binary format with support for all R data types
* Worked around an R bug that made large reduces very slow.
* Backend specific parameters to modify things like number of reducers at the hadoop level
* Automatic library loading in mappers and reducers
* Better data frame conversions
* Adopted a uniform.naming.convention
* New package options API

See [[rmr v1.2 overview]] for details
 
## rmr 1.1 

* Native R serialization/deserialization, which implies that all R objects are supported as key and value, without any conversion boilerplate code. This is the new default. JSON still supported. csv reader/writer also available -- somewhat experimental.
* Multiple backends (hadoop and local); local backend is useful for debugging at small scale; having two backends enforces modular design, opens up further possibilities (rjava, Amazon's EMR, OpenCL have been suggested), forces to clarify semantics.
* Multiple tests of backend equivalence.
* Simpler interface for profiler.
* Equijoins (rough equivalent of merge for mapreduce)
* dfs.empty to check if file is empty
* to.map, to.reduce, to.reduce.all higher order functions to create simple map and reduce functions from regular ones.