###Overview
This R package allows an R programmer to perform statistical analysis via MapReduce on a Hadoop cluster. 

###Prerequisites
* A Hadoop cluster (this package was developed and tested on CDH3 standalone, and CDH3 distributed)
* R installed on each node of the cluster (developed and tested on R 2.13.0). Revolution R Community 4.3 can be used, if you upgrade to RJSONIO 0.95 (which must be downloaded from CRAN, as it is not available in the REVO 2.12 repository) and create a symbolic link from /usr/bin/Revoscript to /usr/bin/Rscript.
* Install the following R packages on each node: RJSONIO (0.95-0 or later recommended), itertools and digest
* rmr itself needs to be installed on each node.
* Make sure that the packages are installed in a default location accessible to all users (R will run on the cluster as a different user from the one who has started the R interpreter where the mapreduce calls have been executed)
* Make sure that the environment variables `HADOOP_HOME` and `HADOOP_CONF` are properly set.
  
Examples:

      HADOOP_HOME=/usr/lib/hadoop  
      HADOOP_CONF=/etc/hadoop/conf
<br>

For people who use RPMs for their deployments, courtesy of jseidman, we have RPMs for rmr and its dependencies (digest, iterators, itertool, rjsonio). These RPMs are available in this repo: https://github.com/jseidman/pkgs. Note that currently there's only CentOS 5.5 64bit RPM's, but the source files to create the RPMs are in the same repo, so it should be easy to build for other RH-based distros. jseidman reports using RPMs along with Puppet to deploy all packages, applications, etc. to their (Orbitz) Hadoop clusters.

## Contents

* [[Changelog]]
* [[Philosophy]]
* [[Tutorial]]
* [[Efficient rmr techniques]] 
* [[Writing composable mapreduce jobs]] 
* [[Use cases]]
