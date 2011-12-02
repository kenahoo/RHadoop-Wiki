#Changelog
## Upcoming in 1.1 (version-1.1 branch)

* Native R serialization/deserialization, which implies that all R objects are supported as key and value, without any conversion boilerplate code. This is the new default. JSON still supported. csv reader/writer also available -- somewhat experimental.
* Multiple backends (hadoop and local); local backend is useful for debugging at small scale; having two backends enforces modular design, opens up further possibilities (rjava, Amazon's EMR, OpenCL have been suggested), forces to clarify semantics.
* Multiple tests of backend equivalence.
* Simpler interface for profiler.
* Equijoins (rough equivalent of merge for mapreduce)
* dfs.empty to check if file is empty
* to.map, to.reduce, to.reduce.all higher order functions to create simple map and reduce functions from regular ones.
