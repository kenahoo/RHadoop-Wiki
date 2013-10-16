Relative paths are relative to the root of the Hadoop distro


| Distribution | HADOOP_CMD   | HADOOP_STREAMING | 
|--------------|--------------|------------------|
|CDH3u2        | `bin/hadoop` | contrib/streaming/hadoop-streaming-0.20.2-cdh3u2.jar | 
|Apache 1.0.2  | `bin/hadoop` | contrib/streaming/hadoop-streaming-1.0.2.jar |
|CDH4.0.0      | `bin/hadoop` | contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.0.0.jar |
|CDH4.2.0      | `bin/hadoop` | contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.2.0.jar |
|Apache 2.1.0.2.0.5.0-67| `bin/hadoop` | share/hadoop/tools/lib/hadoop-streaming-2.1.0.2.0.5.0-67.jar | 

Attempted generalizations:
* The hadoop executable is always under the Hadoop home in `bin/hadoop`, but the simplest way is to run `which hadoop`. This will return an alternate correct setting for `HADOOP_CMD`
* The hadoop streaming jar changes from distro to distro, but a `find $HADOOP_HOME -name hadoop-streaming\*.jar`, if `HADOOP_HOME` is set appropriately. If not, `hadoop classpath | tr : \\n` should give you a good hint. The only exception is CDH4, which packs two streaming jars in some instances, I am not making this up. In that case look for the one with `mr1` in the name.