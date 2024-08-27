## Install packages
install.packages(c("rsconnect", "devtools"),
                 repos = "https://cloud.r-project.org/")

## Load Rsconnect
suppressPackageStartupMessages({
  library(rsconnect)
  library(devtools)
    library(devtools)
})

## Set keys
rsconnect::setAccountInfo(
  name = Sys.getenv("RSCONNECT_NAME"),
  token = Sys.getenv("RSCONNECT_TOKEN"),
  secret = Sys.getenv("RSCONNECT_SECRET")
)

## Install PCAdash package from GitHub using auth_token
devtools::install_github(
    repo       = "spriyansh/PCAdash",
    ref        = "main",
    auth_token = Sys.getenv("PUBLIC_INSTALL_GIT_PAT")
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
