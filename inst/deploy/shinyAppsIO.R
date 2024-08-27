## Install packages
install.packages(c("rsconnect", "remotes", "gitcreds"),
                 repos = "https://cloud.r-project.org/")

## Load Rsconnect
suppressPackageStartupMessages({
  library(rsconnect)
    library(remotes)
    library(gitcreds)
})

## Set keys
rsconnect::setAccountInfo(
  name = Sys.getenv("RSCONNECT_NAME"),
  token = Sys.getenv("RSCONNECT_TOKEN"),
  secret = Sys.getenv("RSCONNECT_SECRET")
)

## Install PCAdash package from GitHub using auth_token
gitcreds_delete(url = "https://github.com")
gitcreds::gitcreds_set("PUBLIC_INSTALL_GIT_PAT")
remotes::install_github(
    repo       = "spriyansh/PCAdash",
    ref        = "main")

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
