#' @title Latent Dimenions X-Y Plot UI Module
#'
#' @description
#' A Shiny UI module for rendering a ggplot2-based X-Y plot for latent Dimensions.
#'
#' @param id A unique identifier for the module.
#'
#' @export
lt_xy_ui <- function(id) {
  ns <- NS(id)
  highcharter::highchartOutput(outputId = ns("lt_xy"))
}

#' @title Longitudinal X-Y Plot Server Module
#'
#' @description
#' A Shiny server module that renders a ggplot2-based scatter plot.
#'
#' @param id A unique identifier for the module.
#' @param df A reactive expression that returns a data frame containing the data to be plotted.
#' @param x_col The column name for the x-axis.
#' @param y_col The column name for the y-axis.
#' @param grp_col The column name for the grouping variable.
#' @param node_df A reactive expression that returns a data frame containing the node data.
#' @param node_x_col The column name for the x-axis of the node data.
#' @param node_y_col The column name for the y-axis of the node data.
#' @param edge_list A reactive expression that returns a list of edge data.
#' @param x_label The label for the x-axis. Defaults to NULL.
#' @param y_label The label for the y-axis. Defaults to NULL.
#'
#' @export
lt_xy_server <- function(id,
                         df,
                         x_col,
                         y_col,
                         grp_col,
                         node_df,
                         node_x_col,
                         node_y_col,
                         edge_list,
                         x_label = "UMAP-1",
                         y_label = "UMAP-2") {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      # Render a plot
      output$lt_xy <- highcharter::renderHighchart({
        # Create the highchart scatter plot with the proper color mapping
        highchart() %>%
          hc_add_series(
            data = df(),
            type = "scatter",
            hcaes(
              x = .data[[x_col]],
              y = .data[[y_col]],
              group = .data[[grp_col]]
            )
          ) %>%
          hc_plotOptions(
            scatter = list(
              marker = list(
                radius = 2.5,
                symbol = "circle"
              ),
              opacity = 1
            )
          ) %>%
          hc_colors(unname(eryth_linear_hspc_colors)) %>%
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
          highcharter::hc_tooltip(
            useHTML = TRUE,
            pointFormatter = highcharter::JS("function() {
                      return '<b>Pseudotime:</b> ' + this.pseudotime.toFixed(2) + '<br/>' +
                             '<b>Cell Type:</b> ' + this.cell_type + '<br/>'}")
          ) %>%
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
          ) %>%
          highcharter::hc_add_series_list(edge_list()) %>%
          highcharter::hc_add_series(
            name = "Trajectory Graph",
            data = node_df(),
            type = "scatter",
            showInLegend = TRUE,
            color = "#fa013c",
            highcharter::hcaes(x = .data[[node_x_col]], y = .data[[node_y_col]]),
            marker = list(radius = 2.5)
          )
      })
    }
  )
}
#
#
# ## Load and fix lt plot
# library(highcharter)
# library(magrittr)
#
# # Load data
# cell_data <- read.table("inst/app/www/data/cell_data_s3.txt", sep = "\t", header = TRUE, stringsAsFactors = TRUE)
# node_df <- read.table("inst/app/www/data/node_df_s3.txt", sep = "\t", header = TRUE, stringsAsFactors = TRUE)
# edge_list <- readRDS("inst/app/www/data/edge_list_s3.RDS")
#
# # Column definitions
# x_col <- "UMAP1"
# y_col <- "UMAP2"
# grp_col <- "cell_type_id"
# x_label <- "UMAP-1"
# y_label <- "UMAP-2"
# node_x_col <- "x"
# node_y_col <- "y"
#
# eryth_linear_hspc_colors <- c(
#     "EEPs" = "skyblue",
#     "MEPs" = "hotpink",
#     "HSCs"  = "limegreen"
# )
#
