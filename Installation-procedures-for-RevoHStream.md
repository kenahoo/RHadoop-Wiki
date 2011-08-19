RevoHStream requires:
1. a Hadoop cluster (developed on CDH3, standalone and distributed)
2. R installed on each node of the cluster (developed on 2.13.0 for distributed and 2.13.1 for standalone)
3. The following R packages on each node: rjson, itertools and digest (also depends on methods but it should be available by default)