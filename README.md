## Shiny

A collection of some of my R shiny apps

Download to local reposititory and run

shiny::runApp("appname")

Eg: shiny::runApp("geneidconvert")

### List of apps

#### [Scatterplots2D](https://ash-apps.shinyapps.io/scatterplots2D/)


#### [Heatmaps](https://ash-apps.shinyapps.io/Heatmaps_Shinyapps/)
For a given tab delimited file, with genenames and scores(Z-scores or vooms), calculates distances (euclidean, pearson, manhattan) and plots dendogram, heatmaps

### [VennDiagram](http://research.scilifelab.se:3838/venndiagram)
For a given differentially expressed file (file containig p,fdr,fc values for genes), dynamically alter the paramters and generate venn-diagram. Numbers in the venndiagrams are clickable which gives the corresponsding genelists. The filtered genes are downloadable.

### [geneidconvert](https://ash-apps.shinyapps.io/geneidconvert/)
For a given list of IDs, based on the data from annotationdbi the ids are converted to desired format.

