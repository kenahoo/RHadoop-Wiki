### Download The Latest Official RHadoop Releases

* [__plyrmr-0.1.0__](http://goo.gl/uIi2KS)
* [__rmr-2.3.0__](http://goo.gl/RA6VaH)
* [__rmr-2.3.0__ for Windows](http://goo.gl/ZQL8sF)
* [__rhdfs-1.0.7__](https://github.com/RevolutionAnalytics/rhdfs/blob/master/build/rhdfs_1.0.7.tar.gz?raw=true)
* [__rhdfs-1.0.7__ for Windows](https://github.com/RevolutionAnalytics/rhdfs/blob/master/build/rhdfs_1.0.7.zip?raw=true)
* [__rhbase-1.2.0__](https://github.com/RevolutionAnalytics/rhbase/blob/master/build/rhbase_1.2.0.tar.gz?raw=true)

We are limiting the listed downloads to the most recent stable version to simplify things and prevent people from downloading obsolete versions (and we say that from experience). If you have a very strong reason to want to install an old version, though, there is a way.

1. Clone the repo for the package you need
2. `git tag`
3. find the tag corresponding to the version you want
4. `git checkout <that-tag>`
5. `R CMD build <path-to-rmr/pkg>`

From the web interface:

1. Go to repo for the package you need (for rmr < 2.0 go to the now retired RHadoop repo)
2. In the Code tab there is a tag link somewhere in the upper right corner
3. Select release of interest and download
4. Unzip
5. `R CMD build <path-to-rmr/pkg>`

Either way, you can now continue with normal installation instructions

###Prerequisites and Installation

See the package specific pages:

* [[rhdfs]]
* [[rhbase]]
* [[rmr]]
* [[plyrmr]]
