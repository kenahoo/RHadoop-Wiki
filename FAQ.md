I think that documentation should be organized better than a FAQ, but if information haven't found its final destination yet, better have some place for it. My goal is to keep the FAQ a staging area and not let it grow to *be* the documentation.

### Exactly what does the RHadoop/rmr developer need to have installed on the hadoop nodes?
R and  all the libraries needed, including rmr and its dependencies and any other library that the developer needs. This is far from perfect and we are aware that some people simply can't install anything on their cluster because of policies, let alone technical difficulties. There seems to be a way around it but it's not very easy to implement. In dev under tools/whirr there is a whirr script that will do this for you, tested on AWS EC2

### What releases of R are supported?
2.13.x 
 
### Is there any mechanism for installing R on the hadoop nodes?
Only if you use whirr. There are also rpm packages maintained by a user, see [rmr]
 
### What happens when there are R code failures?

If they are temporary, hadoop may retry a specific task a number of times. If that number is exceeded, the hadoop job will fail and the mapreduce call will fail. The stderr from R is your friend. In hadoop standalone mode, which is highly recommended for development, it simply shows up in console mixed with somewhat verbose hadoop output. In pseudo distributed and distributed modes it ends up in a file somewhere. This is a [good resource](http://www.cloudera.com/blog/2009/09/apache-hadoop-log-files-where-to-find-them-in-cdh-and-what-info-they-contain/) about that.

### What is debugging like on hadoop?

Not a piece of cake, that's why we provide, starting in 1.1, a local backend where you can run your program without using hadoop (locally) and then debugging is exactly as in regular R. Of course you can not use the local backend with huge data sets. The semantic equivalence of the two backends is corroborated by a battery of tests, but there may still be some kinks to work out. For bugs that appear only at scale, stderr is one way to go. Writing diagnostic output is the other (always to stderr, if you write to stdout in a mapper or reducer you will make it fail). So the progression is: debug with the local backend, then go to hadoop standalone, pseudo-distributed and distributed in this order, which also corresponds to a progression from small test sets to more realistic ones to the real deal. These are general recommendations that are applicable to hadoop programming independent of rmr, with the exception of the local backend which is a specific feature of this package. When a realistic program run costs several hundred dollars, you simply have to minimize your failure rate by developing first at a smaller scale. I sometimes skip pseudo-distributed for simplicity, but certainly used standalone and small datasets at first, and I drop down to local backend when I can't figure it out.
 
### Is there some minimal set of things that an R programmer needs to know about hadoop?

This isn't an easy question, but let me try. Understanding mapreduce is the first priority (the original google paper is still the reference point). Reading a variety of papers with different applications, probably the ones closer to one's problem domain. Cloudera's Hammerbacher has a [collection on Mendeley](http://www.mendeley.com/groups/1058401/mapreduce-applications/) and another one is on the [atbrox blog](http://atbrox.com/2011/11/09/mapreduce-hadoop-algorithms-in-academic-papers-5th-update-%E2%80%93-nov-2011/). Somewhat off topic, I would also recommend acquaint themselves with the parallel programming literature for architectures other than mapreduce.