The problem here we are trying to address is to find frequent itemsets in a large amount of transaction data.
The apriori algorithm is used to find frequent itemsets and association rules efficiently by pruning infrequent candidates. RHadoop give us the ability to find locally frequent itemsets in the mapper, then reducer aggregates the support count for each locally frequent itemset in order to get the global support count for global frequent itemsets.
It's great that we can control how many records are fed to the mapper each time. The global frequent itemsets may not be(or should not be) locally frequent on every fraction of the data, so increasing the size of the local data set will narrow down the probability of such cases. I use the webdoc dataset to mimic transaction data. Each line of the webdoc dataset contains the words appeared in a webpage. Applying apriori on the dataset will give us which combination of words appeared most frequently. It gives us ability to find frequent itemsets from big transaction data parallelly and efficiently. 14 minutes to mining 1.4Gb 1690000 records of data.


```
library(rmr2)
library(arules)

##  Local apriori finding frequent itemsets with !support=0.5!
readRows <- function(file, sep="\n", split=" ", ...){
  tt <- strsplit(
    scan(file, what="list", sep=sep, ...),
    split=split)
  out <- lapply(tt, function(i) as.numeric(i))
  out
}

webdoc <- readRows('/home/hduser/data/webdoc-10000.dat')
tr_webdoc <- as(webdoc, "transactions")
fItemL <- apriori(tr_webdoc, parameter=new("APparameter", support=0.5,target="frequent itemsets", maxlen=5))



##  paralell-apriori finding frequent itemsets with !support=0.3!
##  Reason: Because we are finding "local" frequent itemset's support count in the mapper, then in the reducer we accumulate the support count for each local-frequent itemset. (An itemset with global support 0.5 will not have local support of 0.5 on every datanode, so we will find relative lower local-support 0.3 itemset's support count in the mapper. Then after the mapreduce we can get global-frequent itemset with a higher support by elimanating itemsets below the higher support 0.5, see below.)

papriori =
  function(
    input,
    output = NULL,
    pattern = " ",
    support=0.3,
    maxlen=5 #This is important!
  ){
    
    ## papriori-map
    pa.map =
      function(., lines) {
        if((LL=length(lines))>5000){
          fItems <- apriori(as(lapply(strsplit(
            x = lines,
            split = pattern), unique),
                               "transactions"),
                            parameter=new("APparameter",
                                          support=support,
                                          target="frequent itemsets",
                                          maxlen=maxlen))
          
          recNum <- fItems@info$ntransactions[1]
          
          keyval(as(items(fItems), "list"),
                 fItems@quality$support*recNum)}
        else
          keyval(list("-1"),LL) #Number of records skiped.
      }
    
    ## papiori-reduce
    pa.reduce =
      function(word, counts ) {
        keyval(word, sum(counts))}
    
    ## papiori-mapreduce
    mapreduce(
      input = input ,
      output = output,
      input.format = "text",
      map = pa.map,
      reduce = pa.reduce,
      combine = T)
  }


rmr.options(backend = "hadoop")
rmr.options(keyval.length=10000)

out.hadoop = from.dfs(papriori("/user/hduser/webdoc", pattern = " +"))

items <- out.hadoop$key
distinSkip <- function(x) {
  indicator=FALSE
  if(length(unlist(x))>1)
    indicator=FALSE
  else if(unlist(x)==-1)
    indicator=TRUE
  else
    indicator=FALSE
}

skipedNumRec <- out.hadoop$val[unlist(lapply(items, distinSkip))]
skipedNumRec

totalNumRec<-1692082 #Total number of records
supportH<-out.hadoop$val/(totalNumRec-skipedNumRec)
biggerSup<-supportH>0.5
webKey <- out.hadoop$key[biggerSup]
webVal <- supportH[biggerSup]
fItemH<-new("itemsets")
fItemH@items<-as(webKey,"transactions")
fItemH@quality<-data.frame(support=webVal)
inspect(fItemH)

inspect(fItemL)

```

Contributed by  cyang05 <superman3000@163.com>, with minimal editing by Revolution.