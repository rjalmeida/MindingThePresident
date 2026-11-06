# This script runs all the R Analyses
# install the remotes package, which allows to install specific versions of the other packages.
if(!require(remotes)){install.packages("remotes")}
# install the this.path package, which allows to start the working directory automatically
if(!require(this.path)){remotes::install_version("this.path", version = "2.5.0", repos = "https://cloud.r-project.org", upgrade = FALSE)}
# set the working directory to the location of this file.
setwd(this.path::here())

# run the analysis
source("GC_analysis.R")
source("Correlation_analysis.R")
