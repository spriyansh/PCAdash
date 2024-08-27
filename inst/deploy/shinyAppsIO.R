## Install packages
install.packages(c("rsconnect", "devtools"))

## Load Rsconnect
suppressPackageStartupMessages({
  library(rsconnect)
  library(devtools)
})

## Set keys
rsconnect::setAccountInfo(
  name = Sys.getenv("RSCONNECT_NAME"),
  token = Sys.getenv("RSCONNECT_TOKEN"),
  secret = Sys.getenv("RSCONNECT_SECRET")
)

## PCA dash install
devtools::install_github(
  repo = "spriyansh/PCAdash",
  ref = "main"
)

## Call
suppressPackageStartupMessages({
  library(PCAdash)
})

## Deploy
rsconnect::deployApp(
  appDir = "inst/app",
  appName = "PCAdash",
  logLevel = "verbose"
)
