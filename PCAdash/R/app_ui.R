#' @title Main App UI
#'
#' @description
#' Main UI of the App that contains all the modules.
#'
#' @export
app_ui <- function() {
  shiny::fluidPage(
    shiny::fluidRow(
      shiny::column(4, var_bar_ui("variance_bar")),
      shiny::column(4, ts_xy_ui("metagene")),
      shiny::column(4, lt_xy_ui("latent_plot")),
    ),
    shiny::fluidRow(
      shiny::column(4, multi_ts_xy_ui("contri_genes")),
      shiny::column(4, ts_xy_ui("contri_single")),
      shiny::column(4, var_bar_ui("polar_bar"))
    )
  )
}
