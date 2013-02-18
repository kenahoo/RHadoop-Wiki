### Download Latest Official RHadoop Releases

* [__rmr-2.0.2__](https://github.com/RevolutionAnalytics/rmr2/blob/master/build/rmr2_2.0.2.tar.gz?raw=true)
* [__rhdfs-1.0.5__](https://github.com/RevolutionAnalytics/rhdfs/blob/master/build/rhdfs_1.0.5.tar.gz?raw=true)
* [__rhbase-1.1__](https://github.com/RevolutionAnalytics/rhbase/blob/master/build/rhbase_1.1.tar.gz?raw=true)



We are limiting the listed downloads to the most recent stable version to simplify things and prevent people from downloading obsolete versions (and we say that from experience). If you have a very strong reason to want to install an old version, though, there is a way. 

1. Clone the repo
2. `git tag`
3. find the tag corresponding to the version you want
4. `git checkout <that-tag>`
5. `R CMD build <path-to-rmr/pkg>`

Off you go, you can run vintage rmr-1.0!


###Prerequisites and Installation

See the package specific pages:

* [[rhdfs]]
* [[rhbase]]
* [[rmr]]

Contact: rhadoop@revolutionanalytics.com