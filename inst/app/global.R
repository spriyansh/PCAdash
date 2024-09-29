## Call
suppressPackageStartupMessages({
  library(PCAdash)
  library(magrittr)
  library(promises)
})

## Main plot color
eryth_linear_hspc_colors <- c(
  "EEPs" = "skyblue",
  "MEPs" = "hotpink",
  "HSCs" = "limegreen"
)

#
# options(shiny.autoreload = TRUE)
# shiny::runApp(
#     appDir = "/home/priyansh/gitDockers/PCAdash/inst/app/",
#     launch.browser = TRUE, display.mode = "normal"
# )
