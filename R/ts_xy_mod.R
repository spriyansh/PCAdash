#' @title X-Y Plot UI Module
#'
#' @description
#' A Shiny UI module for rendering a ggplot2-based X-Y plot.
#'
#' @param id A unique identifier for the module.
#'
#' @export
ts_xy_ui <- function(id) {
  ns <- NS(id)
  highcharter::highchartOutput(outputId = ns("ts_xy"))
}

#' @title X-Y Plot Server Module
#'
#' @description
#' A Shiny server module that handles the rendering of a ggplot2-based X-Y plot
#'
#' @param id A unique identifier for the module.
#' @param smoothed_data A reactive expression that returns the smoothed data.
#' @param original_data A reactive expression that returns the original data.
#' @param main_title The main title of the plot.
#' @param x_label The label for the x-axis.
#' @param y_label The label for the y-axis.
#' @param sub_title An optional subtitle for the plot.
#'
#' @import ggplot2
#'
#' @importFrom stats complete.cases
#'
#' @export
ts_xy_server <- function(id,
                         smoothed_data,
                         original_data,
                         main_title = "Main Title",
                         x_label = "x_lable",
                         y_label = "y_lable",
                         sub_title = "Sub Title") {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      output$ts_xy <- highcharter::renderHighchart({
        highcharter::highchart() %>%
          highcharter::hc_add_series(
            name = "trend",
            data = smoothed_data(),
            type = "spline"
          ) %>%
          highcharter::hc_add_series(
            name = "Original",
            data = original_data(),
            type = "scatter"
          ) %>%
          highcharter::hc_xAxis(title = list(text = x_label)) %>%
          highcharter::hc_yAxis(title = list(text = y_label)) %>%
          highcharter::hc_title(text = main_title) %>%
          highcharter::hc_tooltip(shared = TRUE)
      })
    }
  )
}
