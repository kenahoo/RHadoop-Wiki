###Overview
This R package allows an R programmer to perform statistical analysis via MapReduce on a Hadoop cluster. 

###Prerequisites and installation
* A Hadoop cluster (this package was developed and tested on CDH3 standalone, and CDH3 distributed.)
* R installed on each node of the cluster (developed and tested on R 2.13.0). Revolution R Community 4.3 or 5.0 can be used, if you upgrade to RJSONIO 0.95 (which must be downloaded from CRAN, as it is not available in the REVO 2.12 repository) and create a symbolic link from /usr/bin/Revoscript to /usr/bin/Rscript.
* Install the following R packages on each node: RJSONIO (0.95-0 or later recommended), itertools and digest
* rmr itself needs to be installed on each node.
* Make sure that the packages are installed in a default location accessible to all users (R will run on the cluster as a different user from the one who has started the R interpreter where the mapreduce calls have been executed)
* Make sure that the environment variables `HADOOP_HOME` and `HADOOP_CONF` are properly set.
  
Examples:

      HADOOP_HOME=/usr/lib/hadoop  
      HADOOP_CONF=/etc/hadoop/conf
<br>

_Note:  `rmr` needs a backport of a feature called "streaming combiners" that is present in CDH3 to support combiners_

For people who use RPMs for their deployments, courtesy of jseidman, we have RPMs for rmr and its dependencies (digest, iterators, itertool, rjsonio). These RPMs are available in this repo: https://github.com/jseidman/pkgs. Note that currently there's only CentOS 5.5 64bit RPMs, but the source files to create the RPMs are in the same repo, so it should be easy to build for other RH-based distros. jseidman reports using RPMs along with Puppet to deploy all packages, applications, etc. to their (Orbitz) Hadoop clusters.

For people who use EC2 (not EMR), in the dev branch only for now, in the source package under the tools directory, a whirr script to fire up an EC2 rmr cluster. 

If you use Globus Provision, check out this https://github.com/nbest937/gp-rhadoop (very alpha as of this edit), courtesy nbest.

### rmr talk
Come meet the devs! Instead of an IRC channel, we are going to use a Google Hangout. Go to this [calendar](https://www.google.com/calendar/selfsched?sstoken=UU1Dc1pfaW1zVG9FfGRlZmF1bHR8Y2RmZGFiNjUyYWQ4YWU0MWIxYzQ5ZjQwMjU4NmYxNjE) and click on one of the available slots (if you get a slot you can stay for the whole hour containing that slot, it's just a way to limit the number of people, so if you get 9:xx through 9:yy the talk will last from 9 to 10). Be sure you have a Google+ account. A headset and webcam are recommended. When it's time for the hangout, check +Antonio Piccolboni, I will publish the hangout URL before the talk starts (unfortunately, it's impossible to reserve a URL). We are all learning this medium as we go, so please arm yourself with patience.

## Contents

* [[Changelog]]
* [[Philosophy]]
* [[Tutorial]]
* [[Efficient rmr techniques]] 
* [[Writing composable mapreduce jobs]] 
* [[Use cases]]
* [[Getting data in and out]]
* [[FAQ]]
