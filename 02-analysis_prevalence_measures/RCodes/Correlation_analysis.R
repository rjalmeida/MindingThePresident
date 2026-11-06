# Analysis performed with R 4.4.0

# install the remotes package, which allows to install specific versions of the other packages.
if(!require(remotes)){install.packages("remotes")}

if(!require(this.path)){remotes::install_version("this.path", version = "2.5.0", repos = "https://cloud.r-project.org", upgrade = FALSE)}
if(!require(zoo)){remotes::install_version("zoo", version = "1.8-12", repos = "https://cloud.r-project.org", upgrade = FALSE)}
if(!require(bootUR)){remotes::install_version("bootUR", version = "1.0.4", repos = "https://cloud.r-project.org", upgrade = FALSE)}
if(!require(readxl)){remotes::install_version("readxl", version = "1.4.3", repos = "https://cloud.r-project.org", upgrade = FALSE)}
if(!require(ggplot2)){remotes::install_version("ggplot2", version = "3.5.1", repos = "https://cloud.r-project.org", upgrade = FALSE)}

# set the working directory to the location of this file.
setwd(this.path::here())

# Load packages and source functions
library(zoo)
library(bootUR)
library(readxl)
library(ggplot2)
source("input/Functions.R")

# Load the complete dataset and topic labels
data <- read_xlsx("input/PrevalenceMeasures.xlsx")
labels <- read.csv("input/TopicLabels.csv", stringsAsFactors = FALSE)

# extract the prevalences and assign the labels
names_y <- labels[2:3, 2]
names_x <- labels[4:27, 2]

prevalences <- data[, 2:27]
colnames(prevalences) <- c(names_y, names_x)

# Unit Root Tests
set.seed(2124422)
orders <- order_integration(prevalences)
plot_order_integration(orders)

# difference the series accordingly
diffed_prevalences <- orders$diff_data
d_prev_tax <- diffed_prevalences[-1, 1:2]
d_prev_other <- diffed_prevalences[-1, 3:26]

# estimate the correlations and their bootstrap confidence intervals
cors <- boot_cor(d_prev_tax, d_prev_other)

# Store the correlations in a dataframe suitable for plotting
names_cors_y <- factor(rep(names_y, 24), levels = names_y)
names_cors_x <- factor(rep(names_x, each = 2), levels = names_x)
df <- data.frame(tax = names_cors_y, topic = names_cors_x,
                 Estimate = c(cors$cor), Lower = c(cors$ci[, , 1]), 
                 Upper = c(cors$ci[, , 2]), pvalue = c(cors$p_value))

# plot the correlations
ggplot(df, aes(x = topic, y = Estimate)) +
  geom_hline(yintercept = 0) + 
  geom_crossbar(aes(ymin = Lower, ymax = Upper, fill = (Estimate > 0), 
                    alpha = 1 - pvalue^0.3)) +
  facet_grid(rows = vars(tax)) +
  labs(x = "", y = "Correlation") + 
  theme(legend.position = "none",
        axis.text.y = element_text(size = rel(0.8))) +
  coord_flip()

ggsave("output/Figure_A2_Correlations.pdf")
