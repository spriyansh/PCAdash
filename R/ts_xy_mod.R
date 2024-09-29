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
#' @param df A reactive expression that returns the smoothed data.
#' @param time_col The column name for the time variable.
#' @param smoother_col The column name for the smoother variable.
#' @param point_col The column name for the point variable.
#' @param grp_col The column name for the grouping variable.
#' @param x_label The label for the x-axis.
#' @param y_label The label for the y-axis.
#'
#' @importFrom stats complete.cases
#'
#' @export
ts_xy_server <- function(id,
                         df,
                         time_col,
                         smoother_col,
                         point_col,
                         grp_col,
                         x_label = "x_lable",
                         y_label = "y_lable") {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      output$ts_xy <- highcharter::renderHighchart({
        highcharter::highchart() %>%
          hc_colors(unname(eryth_linear_hspc_colors)) %>%
          highcharter::hc_add_series(
            data = df(),
            type = "scatter",
            highcharter::hcaes(
              x = .data[[time_col]], y = .data[[point_col]],
              group = .data[[grp_col]]
            )
          ) %>%
          hc_plotOptions(
            scatter = list(
              marker = list(
                radius = 1.5,
                symbol = "circle"
              ),
              opacity = 0.7
            )
          ) %>%
          highcharter::hc_add_series(
            name = "trend",
            data = df(),
            type = "spline",
            color = "#fa013c",
            highcharter::hcaes(x = .data[[time_col]], y = .data[[smoother_col]])
          ) %>%
          highcharter::hc_xAxis(
            title = list(
              text = x_label,
              style = list(color = "white")
            ),
            lineColor = "white",
            lineWidth = 2,
            gridLineWidth = 0,
            labels = list(style = list(color = "white"))
          ) %>%
          highcharter::hc_yAxis(
            title = list(
              text = y_label,
              style = list(color = "white")
            ),
            lineColor = "white",
            lineWidth = 2,
            gridLineWidth = 0,
            labels = list(style = list(color = "white"))
          ) %>%
          highcharter::hc_tooltip(shared = TRUE) %>%
          hc_add_theme(
            hc_theme(
              line = list(color = "white"),
              chart = list(backgroundColor = "#222222"),
              legend = list(
                itemStyle = list(
                  fontFamily = "Times",
                  color = "white"
                ),
                itemHoverStyle = list(
                  color = "#feff00"
                )
              )
            )
          )
      })
    }
  )
}
