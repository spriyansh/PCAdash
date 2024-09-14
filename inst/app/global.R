## Call
suppressPackageStartupMessages({
  library(PCAdash)
})

## Make Data available globally
data("pTime", package = "PCAdash")
data("metagene_results", package = "PCAdash")
data("cell_type", package = "PCAdash")
data("tsne_coords", package = "PCAdash")
data("counts", package = "PCAdash")

#
# options(shiny.autoreload = TRUE)
# shiny::runApp(
#     appDir = "/home/priyansh/gitDockers/PCAdash/inst/app/",
#     launch.browser = TRUE, display.mode = "normal"
# )
#
# suppressPackageStartupMessages({
#   library(ggplot2)
# })
# source("/home/priyansh/gitDockers/PCAdash/R/dynamic_control_mod.R")
# source("/home/priyansh/gitDockers/PCAdash/R/ts_xy_mod.R")
# source("/home/priyansh/gitDockers/PCAdash/R/lt_xy_mod.R")
# source("/home/priyansh/gitDockers/PCAdash/R/multi_ts_xy_mod.R")
# source("/home/priyansh/gitDockers/PCAdash/R/zzz.R")
# source("/home/priyansh/gitDockers/PCAdash/R/ts_xy_mod.R")
# source("/home/priyansh/gitDockers/PCAdash/R/var_bar_mod.R")
# source("/home/priyansh/gitDockers/PCAdash/R/dynamic_control_mod.R")
# source("/home/priyansh/gitDockers/PCAdash/R/lt_xy_mod.R")
# source("/home/priyansh/gitDockers/PCAdash/R/multi_ts_xy_mod.R")
