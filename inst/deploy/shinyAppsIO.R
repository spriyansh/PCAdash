## Install packages
install.packages(c("rsconnect", "remotes"),
                 repos = "https://cloud.r-project.org/")

## Load Rsconnect
suppressPackageStartupMessages({
  library(rsconnect)
  library(remotes)
})

## Set keys
rsconnect::setAccountInfo(
  name = Sys.getenv("RSCONNECT_NAME"),
  token = Sys.getenv("RSCONNECT_TOKEN"),
  secret = Sys.getenv("RSCONNECT_SECRET")
)

## PCA dash install
remotes::install_github(
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
