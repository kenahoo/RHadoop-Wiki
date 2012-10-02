* Code-heavy docs and any other docs that would benefit from being versioned with the code, such as the compatibility table are under the `rmr2/docs` directory. Code light and long-lived documents are in the wiki.
* Code-heavy documents are formatted in Rmd format. md and html formats are generated from Rmd. They are all checked in for convenience of access but md and html are considered derivative from Rmd (any changes in md and html will be overwritten
* All executable code in documents should be referred to with the knitr externalization feature that is an empty code block with a label like `{r my-chunk-label}`. Labels should be project unique and this is the suggested naming convention: `file-name.function-name.snippet-name`, where snippet-name is based on its intended use and can be empty is a whole function is one chunk. This reduces duplication of code and allows its execution, see the next point.
* All executable code should be under `rmr2/pkg/tests` to be executed with `R CMD check rmr2/pkg` so as to ensure that documents are up to date. Adding assertion is encouraged as it is using the fldegling test package implemented in `quickchek.R` under tests. Labels are added to the code to create chunks:
```
## @knitr chunk-label
code-chunk-here
## @knitr end
```
I believe starting on the first column is mandatory.
* All links from the wiki to the code base should point to the master version because the wiki always refers to the master or stable version. As an exception, for new documents it may be preferable to link to the dev version or other branch than leave a dangling pointer, but a suitable comment should be added to the text. As a further exception, links out of the Changelog point to specific commits, so that they are never updated.