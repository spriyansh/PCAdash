## Install packages
install.packages(c("rsconnect", "remotes"),
  repos = "https://cloud.r-project.org/"
)

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

## Install PCAdash package from GitHub using auth_token
Sys.setenv(GITHUB_PAT = Sys.getenv("GITHUB_PAT"))
remotes::install_github(
  repo       = "spriyansh/PCAdash",
  ref        = "main"
)
Sys.unsetenv("GITHUB_PAT")

## Deploy
rsconnect::deployApp(
  appDir = "inst/app",
  appName = "PCAdash",
  logLevel = "verbose",
  forceUpdate = TRUE
)
