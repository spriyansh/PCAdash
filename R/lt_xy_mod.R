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
      ## Extract Cell Types
      cell_types <- levels(df()[[grp_col]])

      # Generate colors corresponding to the levels of cell_type
      colors <- hcl.colors(length(cell_types), "Dark2")

      # Render a plot
      output$lt_xy <- highcharter::renderHighchart({
        # Create the highchart object without the color aesthetic
        highcharter::hchart(object = df(), type = "point", highcharter::hcaes(
          x = .data[[x_col]], y = .data[[y_col]],
          group = .data[[grp_col]]
        )) %>%
          highcharter::hc_plotOptions(
            scatter = list(
              marker = list(
                radius = 5,
                symbol = "circle"
              ),
              opacity = 0.9
            )
          ) %>%
          # Assign colors to the groups
          highcharter::hc_colors(colors) %>%
          highcharter::hc_add_series(
            name = "Trajectory Graph",
            data = node_df(),
            type = "scatter",
            showInLegend = FALSE,
            highcharter::hcaes(x = .data[[node_x_col]], y = .data[[node_y_col]]),
            marker = list(radius = 4)
          ) %>%
          highcharter::hc_add_series_list(edge_list()) %>%
          # highcharter::hc_title(text = main_title, style = list(color = "white")) %>%
          # highcharter::hc_subtitle(text = sub_title, style = list(color = "white")) %>%
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
                      return '<b>Cell ID:</b> ' + this.cell_id + '<br/>' +
                             '<b>Cell Type ID:</b> ' + this.cell_type_id + '<br/>'}")
          ) %>%
          highcharter::hc_legend(enabled = TRUE) %>%
          highcharter::hc_add_theme(
            highcharter::hc_theme(
              line = list(
                color = "white"
              ),
              chart = list(
                backgroundColor = "#222222"
              ),
              # Remove colors from the theme to prevent overriding
              # colors = colors,
              title = list(
                style = list(
                  color = "white",
                  fontFamily = "Times",
                  fontSize = "25px"
                )
              ),
              subtitle = list(
                style = list(
                  color = "white",
                  fontFamily = "Times",
                  fontSize = "15px"
                )
              ),
              legend = list(
                itemStyle = list(
                  fontFamily = "Times",
                  color = "white"
                ),
                itemHoverStyle = list(
                  color = "yellow"
                )
              )
            )
          )
      })
    }
  )
}
