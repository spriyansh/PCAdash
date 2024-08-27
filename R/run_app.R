#' @title Run PCAdash App
#'
#' @description Main Function to launch the App
#'
#' @author Priyansh Srivastava
#'
#' @export
#'
run_app <- function() {
  options(shiny.autoreload = TRUE)
  shiny::runApp(appDir = system.file("app", package = "PCAdash"))
}
