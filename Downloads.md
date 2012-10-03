### Download Latest Official RHadoop Releases

<font size=4><b>[rmr - 2.0.0](https://github.com/downloads/RevolutionAnalytics/RHadoop/rmr2_2.0.0.tar.gz)</b></font><br>
<font size=4><b>[rhdfs - 1.0.5](https://github.com/downloads/RevolutionAnalytics/RHadoop/rhdfs_1.0.5.tar.gz)</b></font><br>
<font size=4><b>[rhbase - 1.0.4](https://github.com/downloads/RevolutionAnalytics/RHadoop/rhbase_1.0.4.tar.gz)</b></font><br>

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