&nbsp;
# News
* 2/11/2012 New version of rhbase (1.0.2) that installs with thrift 0.8 or greater.
* 2/1/2012 Binary format  now default in dev, passes all normal checks. Please test. 
* 24/1/2012 - Merged branch binary-io into dev. This decision was hastened by the discovery of a R bug affecting the performance of large reduces in all branches for which a workaround has been developed. Unfortunately the patch developed for binary-io couldn't be backported, thus the decision to accelerate the merger of the binary-io into dev. While dev passes all checks in the usual testing, the new binary-io features are still under development. Please consider them more experimental than what normally goes into dev. Also please note some non-backward compatible changes in the API intended to strike a compromise between flexibility and ease of use in the IO department.
* 12/7/2011 - Version 1.1 of the package rmr is available. See the [[Changelog]] for details.
* 9/29/2011 - Version 1.0.1 available - fixes some minor defects with R CMD check tests on the packages 
* 8/10/2011 - Wiki gone live

#About
RHadoop is a collection of three R packages that allow users to manage and analyze data with Hadoop. The packages have been implemented and tested in Cloudera's distribution of Hadoop <a href="http://www.cloudera.com/hadoop/">(CDH3)</a>.  and R 2.13.0.  THe packages have also been tested with <a href="http://www.revolutionanalytics.com/downloads/">Revolution R 4.3 and 5.0</a>


RHadoop consists of the following packages:

<font size=4><b>[[rmr]] </b></font> - functions providing Hadoop MapReduce functionality in R <br>
<font size=4><b>[[rhdfs]] </b></font> - functions providing file management of the HDFS from within R <br>
<font size=4><b>[[rhbase]] </b></font> - functions providing database management for the HBase distributed database from within R <br> <br>

# More information about RHadoop

<a href="http://blog.revolutionanalytics.com/2011/09/mapreduce-hadoop-r.html">Overview of RHadoop</a>, from the Revolution Analytics blog.

<a href="http://www.revolutionanalytics.com/news-events/free-webinars/2011/r-and-hadoop/">Slides and Replay</a> of 30-minute presentation about RHadoop, "Leveraging R in Hadoop Environments". 

<font size=4><b>[[Downloads]] </b</font> <br>
<font size=4><b>[[Tutorial]] </b></font> <br>
<font size=4><b>[[Contribute to the RHadoop project]] </b></font> <br>

Contact: rhadoop@revolutionanalytics.com<br>
Questions: you can use the above address or, if you don't mind sharing your question with everyone, just  [create a new issue](https://github.com/RevolutionAnalytics/RHadoop/issues/new) and tag it as type-question.

