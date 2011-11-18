# New in 1.1
* Native R serialization/deserialization, which implies that all R objects are supported as key or value, without any conversion boilerplate code.This is the new default.
* csv  reader/writer -- somewhat experimental
* Multiple backends (hadoop and local); local backend is useful for debugging at small scale; having two backends enforces modular design, opens up further possibilities (EMR, CUDA have been suggested), forces to clarify semantics.
* Multiple tests of backend equivalence
* Simpler interface for profiler.
* Equijoins (rough equivalent of merge for mapreduce) part of the API
* dfs.empty to check if file is empty