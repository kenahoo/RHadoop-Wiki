The question we are trying to answer here is "will rmr work with my installation of Hadoop?" and the related "what Hadoop distro should I install to work with rmr?" The short answer is CDH3 and higher, Apache 1.0.2 and higher with the exclusion of mr2 (see #115), the new mapreduce framework. Release by release compatibility testing results are collected in the [compatibility](https://github.com/RevolutionAnalytics/RHadoop/blob/master/rmr2/docs/compatibility.md) page. Your best bet may be to run a battery of tests with `R CMD check <path-to-pkg-dir>` and wait (it is pretty extensive). If all checks pass you are most likely to have all the required patches. If they don't, the most likely cause is that your version of hadoop lacks some of the necessary patches or you are running mr2.

If you make your own build, this is a partial list assembled with the help of a user. We can't confirm that these are all the patches you'll ever need. If any users are managing their own builds and running rmr successfully could chip in, that would be very helpful.

1. HADOOP-1722
2. HADOOP-5450
3. MAPREDUCE-764
4. HADOOP-4842 

You can also follow this [writeup](http://blog.ashwanthkumar.in/2012/03/patching-hadoop-to-support-rmr-12.html).

See [Compatibility testing for rmr](http://github.com/RevolutionAnalytics/RHadoop/blob/master/rmr2/docs/compatibility.md) for details.