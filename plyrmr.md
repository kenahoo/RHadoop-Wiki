&nbsp;
## Overview

This R package enables the R user to perform common data manipulation operations, as found in popular packages such as `plyr` and `reshape2`, on very large data sets stored on Hadoop. Like [[rmr]], it relies on Hadoop mapreduce to perform its tasks, but it provides a familiar plyr-like interface while hiding many of the mapreduce details. `plyrmr` provides:

* Hadoop-capable versions of well known data.frame functions: `transform`, `subset`, `mutate`, `summarize`, `melt`, `dcast` and more from packages `base`, `plyr` and `reshape2`.
* Simple but powerful ways of applying any function operating on data.frames to Hadoop data sets: `do` and `magic.wand`.
* Simple but powerful ways of aggregating data: group., group.f, group.together and ungroup.
All of the above can be combined by normal functional composition: delayed evaluation helps mitigating any performance penalty of doing so by minimizing the number of Hadoop jobs launched to evaluate an expression.
* New data frame functions which are also Hadoop-capable that are more suitable for development than some of the above: `select` and `where`.

## Status
We are close to releasing a 0.1 version. As the numbering suggests, the package should be considered work in progress and the API is not cast in stone yet. We seek feedback at an early time to drive further development.
This package has a [Github repo](http://github/com/RevolutionAnalytics/plyrmr), please feel free to enter an issue there to discuss problems, existing or missing features and what not (anything that requires an answer from the devs). For general discussions head to the [RHadoop forum](https://groups.google.com/forum/?hl=en-US&fromgroups#!forum/rhadoop)


## Prerequisites and installation

 * [[rmr]] installed from the dev branch, see [[rmr]] for the necessary steps but instead of downloading the pre-built package start from the [source, dev branch](https://github.com/RevolutionAnalytics/rmr2/archive/dev.zip). Install with `R CMD INSTALL dev.zip`.
 * `plyrmr` installed on each node of a Hadoop cluster together with its dependencies (see the [DESCRIPTION file](https://github.com/RevolutionAnalytics/plyrmr/blob/master/DESCRIPTION), `depends:` line). Install from [source, master branch](https://github.com/RevolutionAnalytics/plyrmr/archive/master.zip) with `R CMD INSTALL master.zip`
 * The need to build from source will go away with the first plyrmr and the next rmr releases, which will be coordinated.
 
## Contents

 * A [Tutorial](https://github.com/RevolutionAnalytics/plyrmr/blob/master/docs/tutorial.md)