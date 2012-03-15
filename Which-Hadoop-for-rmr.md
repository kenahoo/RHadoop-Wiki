The question we are trying to answer here is "will rmr work with my installation of Hadoop?" and the related "what Hadoop distro should I install to work with rmr?" The simplest answer is CDH3. We are currently testing on CDH3 and we will transition to CDH4 in the near future. What if you can't have CDH3 for any number of reasons? Your best bet may be to run a battery of tests with `R CMD check <path-to-pkg-dir>` and wait (it can be pretty slow). If all checks pass you are most likely to have all the required patches. If they don't, the most likely cause is that your version of hadoop lacks some of the necessary patches.

This is a partial list assembled with the help of a user. We can't confirm that these are all the patches you'll ever need. If any users are managing their own builds and running rmr successfully could chip in, that would be very helpful.

1. HADOOP-1722
2. HADOOP-5450
3. MAPREDUCE-764
4. HADOOP-4842 

You can also follow this [writeup](http://blog.ashwanthkumar.in/2012/03/patching-hadoop-to-support-rmr-12.html).

We expect 0.23 to reduce or eliminate the reliance on backported patches. rmr is not tested yet on 0.23. The upcoming Apache Hadoop 1.0.2 will have all these patches, kudos to the Hortonworks folks for including them. I run the checks on an early access snapshot and things are looking good.
