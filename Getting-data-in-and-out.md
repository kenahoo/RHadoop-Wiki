# R data types natively work without additional effort
myData <- list(TRUE, list("nested list", 7.2), seq(1:3), letters[1:4], matrix(1:25, nrow=5,ncol=5))

# Put into HDFS
hdfsFormat <- to.dfs(myData)

# Compute a frequency of object lengths
# Only require input, mapper, and reducer (technically mapper and reducer default to identity)
# Note that myData is passed into mapper as key=item, value=NULL
mrResult <- mapreduce(input=hdfsFormat,
    mapper=function(k,v) keyval(length(k), 1),
    reducer=function(kk,vv) keyval(kk, sum(unlist(vv)))
    )

from.dfs(mrResult)

# However, if using data which is not already a R object (txt, csv, tsv, JSON, etc)
# it is necessary to define a textinputformat which can handle the input
# Hadoop Streaming feeds data into R line by line - as separated by newlines
# textinputformat is a function which takes the line of input and handles it for the rest of the processing
# textinputformat output is then sent to the mapper stage as (key, value) pair

# rawtextinput returns line as key=NULL, value=line text

filesystemData <- "/home/rhadoop/bagofwords.txt"
hdfsData <- "/rhadoop/bagofwords.txt"
hdfs.put(filesystemData, hdfsData)

# Wordcount
mrResult <- mapreduce(input=hdfsData,
    textinputformat=rawtextinputformat,
    mapper=function(k,v){
        words <- strsplit(v, pattern=" ")[[1]]
        sapply(words, function(word) keyval(word, 1))
    },
    reducer=function(kk, vv) keyval(kk, sum(unlist(vv)))
    )

# to define your own textinputformat (eg to handle tsv)
myTSVReader <- function(line){
    delim <- strsplit(line, split="\t")[[1]]
    keyval(delim[[1]], delim[2:length(delim)]) # first column is the key, note that column indexes moved by 1
}

# Frequency count on input column two of the tsv data
# data comes into mapper already delimitted
mrResult <- mapreduce(input=hdfsData,
    textinputformat=myTSVReader,
    mapper=function(k,v) keyval(v[[1]], 1),
    reducer=function(kk,vv) sapply(vv, sum(unlist(vv))
    )

# or if you want named columns, this would be specific to your data file
mySpecificTSVReader <- function(line){
    delim <- strsplit(line, split="\t")[[1]]
    keyval(delim[[1]], list(location=delim[[2]], name=delim[[3]], value=delim[[4]]))
}

# You can then use the list names to directly access your column of interest for
# manipulations
mrResult <- mapreducer(input=hdfsData,
    textinputformat=mySpecificTSVReader,
    mapper=function(k, v) { 
        if (v$name == "blarg"){
            keyval(k, log(v$value))
        }
    },
    reducer=function(kk, vv) keyval(kk, mean(unlist(vv)))
    )

# To get your data out - say you input file, apply column transformations, add columns, and
# want to output a new csv file
# Just like textinputformat -must define a textoutputformat
myCSVOutput <- function(k, v){
    keyval(paste(k, paste(v, collapse=","), sep=","))
}

# This time define an output so can easily extract from hdfs
# (cannot hdfs.get from a Rhadoop big data object, unfortunately)
mapreduce(input=hdfsData,
    output="/rhadoop/output/",
    textoutputformat=myCSVOutput,
    mapper=function(k,v){
        # complicated function here
    },
    reducer=function(k,v) {
        #complicated function here
    }
    )

# Save output to the filesystem
hdfs.get("/rhadoop/output/", "/home/rhadoop/filesystemoutput/")

# Within /home/rhadoop/filesystemoutput/ will now be your CSV data (likely split into multiple part- files according to the Hadoop way).