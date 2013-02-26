&nbsp;
#About
RHadoop is a collection of three R packages that allow users to manage and analyze data with Hadoop. The packages have been implemented and tested in Cloudera's distribution of Hadoop <a href="http://www.cloudera.com/hadoop/">(CDH3) & (CDH4)</a>.  and R 2.15.0.  THe packages have also been tested with <a href="http://www.revolutionanalytics.com/downloads/">Revolution R 4.3, 5.0, and 6.0</a>. For rmr see [Compatibility](https://github.com/RevolutionAnalytics/rmr2/blob/master/docs/compatibility.md).


RHadoop consists of the following packages:

* [[rmr]] - functions providing Hadoop MapReduce functionality in R 
* [[rhdfs]] - functions providing file management of the HDFS from within R 
* [[rhbase]] - functions providing database management for the HBase distributed database from within R

# More information about RHadoop

* Having problems?, post a message on the [RHadoop Google Group](https://groups.google.com/forum/#!forum/rhadoop)
* [Overview of RHadoop](http://blog.revolutionanalytics.com/2011/09/mapreduce-hadoop-r.html), from the [Revolution Analytics blog](http://blog.revolutionanalytics.com).
* [Slides and Replay](http://www.revolutionanalytics.com/news-events/free-webinars/2011/r-and-hadoop/) of 30-minute presentation about RHadoop, "Leveraging R in Hadoop Environments". 
* [R in a Nutshell, 2nd edition](http://shop.oreilly.com/product/0636920022008.do) devotes a good part of the last chapter to RHadoop. _"The most mature (and best integrated) project for R and Hadoop is RHadoop."_
* [[Downloads]] 
* [[Learning Resources]]
* [[Contribute to the RHadoop project]] 
* [Live from the net](https://friendfeed.com/rhadoop)

Contact: rhadoop@revolutionanalytics.com

Questions: Please participate in our [discussion group](https://groups.google.com/forum/?fromgroups#!forum/rhadoop). For private questions, please use the above email address.

# News
* 2/25/2013 rmr 2.1.0 released, improves speed, adds in-memory combiners and more vectorization, status and counters, hbase input and more. See [[Changelog]].
* 2/5/2013 Created package-specific repos to better support development. See the [announcement](https://groups.google.com/d/topic/rhadoop/CwyaTCdiDdg/discussion).
* 12/4/2012 rmr 2.0.2 released with ligther dependencies and multiple bug fixes. See [[Changelog]].
* 10/29/2012 rmr 2.0.1 released with multiple bug fixes and tested against most major Hadoop distros. See [[Changelog]].
* 10/18/2012 rhbase (1.1) added 'filterstring' support for scan operations on HBase tables (HBase 0.92 or >)
* 10/1/2012 rmr 2.0 released, simplest and fastest rmr yet, makes everything vectorized and gives first class status to structured data. See [[Changelog]]
* 9/10/2012 branched rmr-2.0 to prepare for the next release. Also provided a tgz file for download. Many changes and documentation still mostly out of date. Try it if you are able to read the source code. Feedback is welcome.
* 7/30/2012 rmr 1.3.1 tested on major Hadoop distros and Rmd docs &mdash; see [[Changelog]]. 
* 7/17/2012 rhdfs (1.0.4) change to handle different classpaths in the init function
* 7/13/2012 rmr 1.3 with vectorized API &mdash; see [[Changelog]].
* 5/18/2012 rhdfs (1.0.3) bug fix in function hdfs.file
* 4/14/2012 rhbase (1.0.4) and rhdfs (1.0.2) minor bug fixes and some cleanup for R CMD check
* 3/30/2012 rmr 1.2.2 fixes from.dfs for some obscure platforms and prepares for apache 1.0.2 compatibility (more flexible w.r.t. hadoop layout)
* 3/13/2012 New version of rhbase (1.0.3) that supports both "native" and "raw" serialization 
* 2/27/2012 rmr version 1.2 with binary formats and other goodies available &mdash; see [[Changelog]].
* 2/11/2012 New version of rhbase (1.0.2) that installs with thrift 0.8 or greater.
* 2/1/2012 Binary format  now default in dev, passes all normal checks. Please test. 
* 24/1/2012 - Merged branch binary-io into dev.Please note some non-backward compatible changes in the API intended to strike a compromise between flexibility and ease of use in the IO department.
* 12/7/2011 - Version 1.1 of the package rmr is available. See the [[Changelog]] for details.
* 9/29/2011 - Version 1.0.1 available - fixes some minor defects with R CMD check tests on the packages 