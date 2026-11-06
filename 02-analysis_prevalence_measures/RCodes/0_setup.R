# Analysis performed with R 4.4.0

# install the remotes package, which allows to install specific versions of the other packages.
if(!require(remotes)){install.packages("remotes")}

# install the used version of the packages
# NOTE: this may override existing package versions on your system
remotes::install_version("this.path", version = "2.5.0", repos = "https://cloud.r-project.org", upgrade = FALSE)
remotes::install_version("glmnet", version = "4.1-8", repos = "https://cloud.r-project.org", upgrade = FALSE)
remotes::install_version("zoo", version = "1.8-12", repos = "https://cloud.r-project.org", upgrade = FALSE)
remotes::install_version("readxl", version = "1.4.3", repos = "https://cloud.r-project.org", upgrade = FALSE)
remotes::install_version("bootUR", version = "1.0.4", repos = "https://cloud.r-project.org", upgrade = FALSE)
remotes::install_version("ggplot2", version = "3.5.1", repos = "https://cloud.r-project.org", upgrade = FALSE)

# set the working directory to the location of this file.
setwd(this.path::here())

# install the HDGCvar package; included in the replication materials
remotes::install_local("input/HDGCvar_0.2.0.tar.gz", upgrade = FALSE)
