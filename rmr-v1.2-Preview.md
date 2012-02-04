**This is a draft document, we haven't even branched a release candidate yet**

#What is coming in 1.2
Despite the minor release change, there are plenty of new features in this release, some backward incompatible API changes and some serious refactoring behind the scenes.

##I/O 

###Binary I/O

We now support binary I/O formats. This gives you great I/O flexibility but also increase complexity, so we tried to hide this complexity
for several common formats. Gone are the several options to `mapreduce` that controlled I/O formats. There are only two arguments,
`input.format` and `output.format` (just `format` for `from.dfs` and `to.dfs`) and in the simplest case they take a string as value,
like `"csv"`or `"json"`, and everyting works. If you want the full power, you can create new formats with `make.input.format` and
`make.output.format`. They accept a `mode`, `"binary"` or `"text"`, an R function and a java class as arguments. These get called in the following order on each record: 

<pre>
java input format class -> 
  r input format function -> 
    map -> 
      reduce -> 
        r output format function -> 
          java output format class
</pre>

This gives you a lot of flexibility, but you need to make sure that the Java class and the r function, both on the input and output sides,
 agree on a common format. For instance
 One suggested route to support a variety of Hadoop-related formats is writing or using existing Java classes to convert whatever format to a simple serialization format called typedbytes (HADOOP-1722), then use
the `rmr:::typed.bytes.input.format` function to get a key value pair of R objects. Alternatively, you can use JSON as the intermediate format. For instance you could use `org.apache.avro.mapred.AvroAsTextInputFormat` to convert Avro to JSON and then use `rmr:::json.input.format` to go from JSON to a key-value pair. It should be as simple as 

```
mapreduce(<other args>, 
  input.specs = make.input.specs(format = rmr:::json.input.format, 
  streaming.input.format = "org.apache.avro.mapred.AvroAsTextInputFormat", 
  mode = "text"))
```

but I am sure that there will be some kinks to iron out. 
The converse is true on the output side. Issues have been
created for HBase, Avro, Mahout and Cassandra compatibility (#19, #44, #39 and #20) and now people who need those are in a position to get
things done, with a little work. Work on #19 has already started. Pull requests welcome.

###Internal format is now binary
As hinted above we now use internally and as default a binary format, a combination of R native serde and typedbytes. This gives us the highest compatibility with R, meaning any R value should be a valid key or value in the mapreduce sense. For instance, models used to cause errors, now they don't. The goal is to support everything, if you find exceptions please do not hesitate to submit an issue. If you have data stored in the old native format, don't fret, it has now been renamed `native.text`, but we would suggest to wind its use down.

###Loose ends

* Support for comments in CSV format
* JSON format reads one or two JSON objects per row, uses improvements in `RJSONIO` library instead of workarounds


##Mapreduce Galore

###The odd case of the slow reduce
 
If you didn't know, appends are not constant time in R.

```
> t = 16000
> system.time({ll = list(); for (i  in 1:t) ll[[i]] = i})
   user  system elapsed 
  0.794   0.313   1.105 
> t = 32000
> system.time({ll = list(); for (i  in 1:t) ll[[i]] = i})
   user  system elapsed 
  3.274   1.545   4.818 
```

You see? Input doubles, time quadruples. We didn't know until a client run Really Big Reduces, and it hurt. This should be fixed right in the
interpreter. In the meantime, since we don't let our users down, we cracked the code and we have fast appends in the reduce phase. You can run much bigger reduces and still go
home for dinner. But let's not get complacent. The number of reduces should still scale with the size of your input and we are still
allocating one big list for each key, so memory is a constraint. These are the rules of engagement.

###Backend specific parameters

We've always said that we want to design a tight mapreduce abstraction, to the point that it's possible to have multiple backends, the most
important of which is of course hadoop. Well, real life hit and we had to punch a small hole in the abstraction for performance tuning. You can do things like setting the number of reducers on a per-job basis. See the `performance.tuning` parameter to `mapreduce` for details.

###Automatic library loading

Need to use additional libraries in your map or reduce functions? If they are loaded at `mapreduce` invocation they should be available with no additional fuss, like a lapply.

```
library(rmr)
library(MASS)

from.dfs(
  mapreduce(
   to.dfs(lapply(1:5, function(i) keyval(NULL,data.frame(x=rnorm(10), y = rnorm(10))))), 
   map = function(k,v) keyval(NULL,rlm(y~x, v))))
```

###Data.frame conversions

Hadoop doesn't impose a lot of structure on your data, which is part of what makes it so successful. To reflect that, we use lists in crucial places of the API. `from.dfs` returns a list and the reduce function accepts a list of
values. But the special case where data.frames would be more than enough and more convenient is common enough to support it with specific
options in `from.dfs` and `mapreduce`. The problem is that turning a list into a data.frame under weak assumptions on the contents of the list is not easy and not even well
defined. We decided to aim for a data.frame with atomic cells and let it fail when it's not
possible. This is work in progress, more than the rest of the package, and we found some broken cases that needed attention, and simplified a very hacky implementation. Please
give it a spin and do not hesitate to give feedback.

###Loose ends

Tired of that console verbiage? Set `verbose` to `FALSE` when things are running smoothly. Want to break one large file into multiple parts? Use `scatter`.


##Naming conventions

We looked at the code for v1.1 and realized we had a mix of dot-separated, CamelCase and nonseparated identifiers and while I think there are more important factors to code quality, this was a relatively easy fix that brings a little more readability and writability. We
went with dot-separated across the board. This will break your code in multiple places but fixing it is as simple as search and replace. For example, `reduceondataframe` becomes `reduce.on.data.frame`. The exceptions are:

* `mapreduce`: this spelling is used elsewhere often enough that I consider it a portmanteau of map and reduce. So it's a new word and doesn't need separators.
* `keyval`: used often enough that a shorter form seems warranted.

##New package options API

Instead of having one call per option, we decided to go with the pair `rmr.options.set` and `rmr.options.get` to set and get any option, in preparation for future features.

