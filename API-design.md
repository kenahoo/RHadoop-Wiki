1. Explicit transfer from a to HDFS with `rhread` and `rhwrite`
   1. Impossible for revoMapReduce to make an educated guess on what the input means: is a list of character strings a list of HDFS paths or literally the input
   1. It's going to be difficult to decide automatically whether to keep results in HDFS or bring them into memory and it's very unlikely we can make it transparent to the programmer, so `rhread` has to be a deliberate decision
   1. We could have added options to `revoMapReduce` to achieve this, but they would have been extremely complicated. Imagine a multiple input job where some inputs come from memory and some from HDFS: not a common use case but a consequence of supporting both types of input, multuple inputs and having a goal of orthogonality
   1. Finally we opted for a separation of concerns, `revoMapReduce` inputs and outputs are on HDFS; `rhread` and `rhwrite` do the transfer.
   
1. Not a direct equivalent to lapply and tapply
  1. We can easily simulate them but if we teach the user to use them as the basic primitives we end up with more jobs that are map-only or reduce-only and could be easily combined into simpler jobs. If we do that we also need to offer a "planner" feature, like Cascading, Hive etc have to merge some of the map only and reduce only jobs into a smaller number of more complicated jobs. This is a higer level interface and should be left to a separate package built on top of `RevoHStream`, if there is demand for it
