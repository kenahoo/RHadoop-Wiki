&nbsp;
## Overview

This R package enables the R user to perform common data manipulation operations, as found in popular packages such as `plyr` and `reshape2`, on very large data sets stored on Hadoop. Like [[rmr]], it relies on Hadoop mapreduce to perform its tasks, but it provides a familiar plyr-like interface while hiding many of the mapreduce details. `plyrmr` provides:

* Hadoop-capable equivalents of well known data.frame functions: `transmute` and `bind.cols` generalize over `transform`, and `summarize`;  `select` from `dplyr`; `melt`, `dcast` from `reshape2`; sampling, quantiles and counting and more.
* Simple but powerful ways of applying any function operating on data.frames to Hadoop data sets: `gapply` and `magic.wand`.
* Simple but powerful ways of grouping data: `group`, `group.f`, `gather` and `ungroup`.
* All of the above can be combined by normal functional composition: delayed evaluation helps mitigating any performance penalty of doing so by minimizing the number of Hadoop jobs launched to evaluate an expression.
 
## Status
The current version has a major release number of zero (0.x.y). As the numbering suggests, the package should be considered work in progress and the API is not cast in stone yet. We seek feedback at an early time to drive further development.
This package has a [Github repo](http://github/com/RevolutionAnalytics/plyrmr), please feel free to enter an issue there to discuss problems, existing or missing features and what not (anything that requires an answer from the devs). For general discussions head to the [RHadoop forum](https://groups.google.com/forum/?hl=en-US&fromgroups#!forum/rhadoop).


## Prerequisites and installation

 * [[rmr]] 3.1 or higher.
 * `plyrmr` installed on each node of a Hadoop cluster together with its dependencies (see the [DESCRIPTION file](https://github.com/RevolutionAnalytics/plyrmr/blob/master/DESCRIPTION), `depends:` line). 
```

To download `plyrmr` see [[Downloads]].
 
 
## Contents

 * A [Tutorial](https://github.com/RevolutionAnalytics/plyrmr/blob/master/docs/tutorial.md)