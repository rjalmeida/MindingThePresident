# Analysis performed with R 4.4.0

# install the remotes package, which allows to install specific versions of the other packages.
if(!require(remotes)){install.packages("remotes")}

# install the used version of the packages
if(!require(this.path)){remotes::install_version("this.path", version = "2.5.0", repos = "https://cloud.r-project.org", upgrade = FALSE)}
if(!require(glmnet)){remotes::install_version("glmnet", version = "4.1-8", repos = "https://cloud.r-project.org", upgrade = FALSE)}
if(!require(zoo)){remotes::install_version("zoo", version = "1.8-12", repos = "https://cloud.r-project.org", upgrade = FALSE)}
if(!require(readxl)){remotes::install_version("readxl", version = "1.4.3", repos = "https://cloud.r-project.org", upgrade = FALSE)}

# set the working directory to the location of this file.
setwd(this.path::here())

# install the HDGCvar package; included in the replication materials
if(!require(HDGCvar)){remotes::install_local("input/HDGCvar_0.2.0.tar.gz", upgrade = FALSE)}

# Load packages and source functions
library(zoo)
library(HDGCvar)
library(parallel)
library(readxl)
source("input/Functions.R")

# Load prevalence data
data_prev <- as.data.frame(read_xlsx("input/PrevalenceMeasures.xlsx"))
labels <- read.csv("input/TopicLabels.csv", stringsAsFactors = FALSE)

# extract the prevalences and assign the labels
names_y <- labels[2:3, 2]
names_x <- labels[4:27, 2]

prevalences <- data_prev[, 2:27]
colnames(prevalences) <- c(names_y, names_x)

# Load macro data
macro_data <- as.data.frame(read_xlsx("input/Data.xlsx"))
control_vars <- macro_data[, c(2:5, 7, 12:15, 8, 16)]
tax_measures <-  macro_data[, c(6, 17, 18:23, 9:11)]

prevalences <- zoo(prevalences, order.by = as.yearqtr(data_prev[, 1]))
control_vars <- zoo(control_vars, order.by = as.yearqtr(macro_data[, 1]))
tax_measures <- zoo(tax_measures, order.by = as.yearqtr(macro_data[, 1]))


# Macro controls growth rates (not spending_news)
controls_gr <- control_vars[-1, ]
for (i in c(1:10)) {
  controls_gr[, i] <- diff(log(control_vars[, i]))
}

range <- 23:227
controls_gr <- controls_gr[range, ]

# Tax measures growth rates (not d_revenue_ratio, RR & MR)
tax_gr <- tax_measures[-1, ]
for (i in c(1, 8:11)) {
  tax_gr[, i] <- diff(log(tax_measures[, i]))
}

tax_gr <- tax_gr[range, ]

prevalences <- prevalences[1 + range, ]

# Nr of lags included
n_lags <- 6

#### Granger causality to tax news measures from others ####

# set the variables from which GC is investigated
GCfrom <- list(c("Tax Increase", "Tax Decrease"))
# set the variables to which GC is investigated
GCto <- as.list(c(colnames(tax_gr), names_x, colnames(controls_gr)))

# create lists which contain the tests to be performed
nGCto <- length(GCto)
nGCfrom <- length(GCfrom)
GC_from_Tax <- vector("list", length = nGCto * nGCfrom)
for (i in 1:nGCto) {
  for (j in 1:nGCfrom) {
    GC_from_Tax[[(i - 1) * nGCfrom + j]] <- list(GCto = GCto[[i]], GCfrom = GCfrom[[j]])
  }
}

#### Granger causality to tax news measures from others ####

# set the variables to which GC is investigated
GCto <- list(c("Tax Increase", "Tax Decrease"))
# set the variables from which GC is investigated
GCfrom <- as.list(c(colnames(tax_gr), names_x, colnames(controls_gr)))

# create lists which contain the tests to be performed
nGCto <- length(GCto)
nGCfrom <- length(GCfrom)
GC_to_Tax <- vector("list", length = nGCto * nGCfrom)
for (i in 1:nGCto) {
  for (j in 1:nGCfrom) {
    GC_to_Tax[[(i - 1) * nGCfrom + j]] <- list(GCto = GCto[[i]], GCfrom = GCfrom[[j]])
  }
}

# combine both lists
GCall <- append(GC_from_Tax, GC_to_Tax)

# variables only included when object of the test
GC_only <- cbind(prevalences[, 1:2], tax_gr[, 3:11])
# variables always included (controls)
GC_always <- cbind(tax_gr[, 1:2], prevalences[, 3:26], controls_gr)

# Set parallel computing
n_cores <- detectCores() - 1
cl <- makeCluster(n_cores, setup_strategy = "sequential")
clusterSetRNGStream(cl, sample.int(2^20, size = 1))
clusterExport(cl = cl, Filter(function(x) is.function(get(x, .GlobalEnv)), ls(.GlobalEnv)))
clusterEvalQ(cl = cl, library(glmnet))
clusterEvalQ(cl = cl, library(HDGCvar))

# Perform the GC tests
test_list <- parLapply(cl, GCall, wrap_HDGC_VAR, GC = GC_only,
                       controls = GC_always, p = n_lags, bound = 0.5 * length(range))

# stop the parallel cluster
stopCluster(cl)

# simplify the results
out <- HDGCvar:::simplify_list(test_list, GCall)

# Process the p-values
p_values <- out$tests[2, 2, ]

write.csv(p_values, "../MatlabCodes/DataCopy/GC_pvalues.csv")


