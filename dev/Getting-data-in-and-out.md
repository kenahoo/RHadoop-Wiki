* This document responds to several inquiries on data formats and how to get data in and out of the rmr system
* Still more a collection of snippets than anything organized
* Code is NOT tested
* Thanks Damien for the examples and Koert for conversations on the subject

Internally `rmr` uses JSON-ish representation (see below) internally in v1.0 and the R native serde in v1.1 (We just cut a branch for the
release candidate as of this writing). The goal is to make you forget about representation issues. But what happens at the boundary of the
system, when you need to get non-rmr data in and out of it? Of course `rmr` has to be able to read and write a variety of formats to be of
any use. This is what is available and how to extend it.

1. JSON-ish. It is actually <JSON\tJSON\n> so that streaming can tell key and value. Your data may not be in this form, but almost any
language has decent JSON libraries. Default in v1.0, still available in v1.1. and for the foreseeable future. Parsed in C for efficiency,
should handle large objects.
2. CSV added support in version 1.1. A variety of actual formats modeled after `read.table`
4. Raw: for english text. key is null and value is a string, one per line. Please don't use it for anything else.
5. Write your own parser in R: `mycustomformat = function(line) <parsing work here> keyval(k,v);
mapreduce(<other args here>, textinputformat = mycustomformat)`
that is, it gets a line of text, parses it and returns a keyval pair, which goes straight into the mapper
6. Write a class that reads java key-value and outputs a line of text, then parse that in R as per the above points. The default is class
`TextInputFormat` and there is also a class `SequenceFileAsTextInputFormat`. You specify that in the `inputformat` option to `mapreduce`

R data types natively work without additional effort (for matrices, functions, models, promises it is true from v1.1, hopefully all bases
covered now)

```r
myData <- list(TRUE, list("nested list", 7.2), seq(1:3), letters[1:4], matrix(1:25, nrow = 5,ncol = 5))
```

Put into HDFS:
```r
hdfsFormat <- to.dfs(myData)
```
myData is coerced to a list and each element of a list becomes a record.

Compute a frequency of object lengths.  Only require input, mapper, and reducer. Note that `myData` is passed into the mapper, record by
record, as `key = item, value=NULL`. From v1.1 this changes to `key = NULL, value = item` to highlight the fact that key is pretty much
unimportant other than between the mapper and the reducer, where it determines the grouping.

```r
mrResult <- mapreduce(input = hdfsFormat,
    map = function(k,v) keyval(length(k), 1),
    reduce = function(k,vv) keyval(k, sum(unlist(vv)))
    )

from.dfs(mrResult)
```

However, if using data which was not generated with rmr (txt, csv, tsv, JSON, log files, etc) it is necessary to specify a text input format. Hadoop Streaming feeds data into R line by line - as separated by newlines. The argument `textinputformat` to
`mapreduce` accepts a function which takes one line of input and handles it returning a key-value pair which is then passed to the mapper.
`rawtextinput` returns line as `key = NULL, value = line` text

```r
filesystemData <- "/home/rhadoop/bagofwords.txt"
hdfsData <- "/rhadoop/bagofwords.txt"
hdfs.put(filesystemData, hdfsData)
```

In v1.1 we have `csvtextinput` which is actually a higher level function that takes arguments modeled after `read.table` and returns a
function that can be passed to `mapreduce` as `textinputformat`, as in `mapreduce(..., textinputformat = csvtextinputformat(sep =
","))`. There is also `jsontextinputformat` which is 2 tab-separated JSON objects. Equivalent functions exist on the output side.

Wordcount: please note the use of `textinputformat`

```r
mrResult <- mapreduce(input = hdfsData,
    textinputformat = rawtextinputformat,
    map = function(k,v){
        words <- strsplit(v, pattern = " ")[[1]]
        sapply(words, function(word) keyval(word, 1))
    },
    reduce = function(k, vv) keyval(k, sum(unlist(vv)))
    )
```

To define your own `textinputformat` (e.g. to handle tsv)

```r
myTSVReader <- function(line){
    delim <- strsplit(line, split = "\t")[[1]]
    keyval(delim[[1]], delim[-1]) # first column is the key, note that column indexes moved by 1
}
```

Frequency count on input column two of the tsv data, data comes into map already delimited

```r
mrResult <- mapreduce(input = hdfsData,
    textinputformat = myTSVReader,
    map = function(k,v) keyval(v[[1]], 1),
    reduce = function(k,vv) sapply(vv, sum(unlist(vv))
    )
```

Or if you want named columns, this would be specific to your data file

```r
mySpecificTSVReader <- function(line){
    delim <- strsplit(line, split = "\t")[[1]]
    keyval(delim[[1]], list(location = delim[[2]], name = delim[[3]], value = delim[[4]]))
}
```

You can then use the list names to directly access your column of interest for manipulations
```r
mrResult <- mapreduce(input = hdfsData,
    textinputformat = mySpecificTSVReader,
    map = function(k, v) { 
        if (v$name == "blarg"){
            keyval(k, log(v$value))
        }
    },
    reduce = function(k, vv) keyval(k, mean(unlist(vv)))
    )
```

To get your data out - say you input file, apply column transformations, add columns, and want to output a new csv file
Just like textinputformat -must define a textoutputformat

```r
myCSVOutput <- function(k, v){
    keyval(paste(k, paste(v, collapse = ","), sep = ","))
}
```

In v1.1 this should be as simple as

```r
myCSVOutput = csvtextoutputformat(sep = ",")
```

This time providing output argument so one can extract from hdfs (cannot hdfs.get from a Rhadoop big data object)

```r
mapreduce(input = hdfsData,
    output = "/rhadoop/output/",
    textoutputformat = myCSVOutput,
    map = function(k,v){
        # complicated function here
    },
    reduce = function(k,v) {
        #complicated function here
    }
    )
```

Save output to the local filesystem

```r
hdfs.get("/rhadoop/output/", "/home/rhadoop/filesystemoutput/")
```

Within /home/rhadoop/filesystemoutput/ will now be your CSV data (likely split into multiple part- files according to the Hadoop way).
