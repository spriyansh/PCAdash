#' @title Ordered Bar Plot UI Module
#'
#' @description
#' A Shiny UI module for rendering a ggplot2-based Bar plot.
#'
#' @param id A unique identifier for the module.
#'
#' @export
var_bar_ui <- function(id) {
  ns <- NS(id)
  highcharter::highchartOutput(outputId = ns("var_bar"))
}

#' @title Variance Bar Plot Server Module
#'
#' @param id A unique identifier for the module, used to distinguish this module's
#' UI and server components from others within a Shiny application.
#' @param df A reactive expression that returns a data frame containing the data to be plotted.
#' @param x_col The column name for the x-axis.
#' @param y_col The column name for the y-axis.
#' @param sd_col The column name for the standard deviation values.
#' @param x_label The label for the x-axis. Defaults to NULL.
#' @param y_label The label for the y-axis. Defaults to NULL.
#' @param type The type of plot to render. Defaults to "column".
#'
#' @export
var_bar_server <- function(id,
                           df,
                           x_col,
                           y_col,
                           sd_col = NULL,
                           x_label = NULL,
                           y_label = NULL,
                           type = "column") {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      # Render a plot
      output$var_bar <- highcharter::renderHighchart({
        if (type == "column") {
          highcharter::hchart(
            object = df(),
            type = "column",
            highcharter::hcaes(x = .data[[x_col]], y = .data[[y_col]]),
          ) %>%
            highcharter::hc_add_series(
              df(),
              "errorbar",
              highcharter::hcaes(x = .data[[x_col]], y = .data[[y_col]], low = .data[[y_col]] - .data[[sd_col]], high = .data[[y_col]] + .data[[sd_col]]),
              enableMouseTracking = TRUE,
              showInLegend = FALSE
            ) %>%
            highcharter::hc_plotOptions(
              errorbar = list(
                color = "#fde725",
                stemWidth = 1
              ),
              column = list(
                color = "#21918c",
                borderColor = "#f98e09"
              )
            ) %>%
            # highcharter::hc_title(text = main_title) %>%
            # highcharter::hc_subtitle(text = main_title) %>%
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
        } else if (type == "bar") {
          # Create a vector of colors based on the loading_col values
          colors <- ifelse(df()[[y_col]] > 0, "seagreen", "hotpink") # seagreen for positive, brown for negative

          # Create the bar chart with conditional coloring
          hcp <- highcharter::hchart(
            object = df(),
            type = "bar",
            highcharter::hcaes(x = .data[[x_col]], y = .data[[y_col]])
          ) %>%
            highcharter::hc_colors(colors) %>% # Apply the colors vector
            highcharter::hc_plotOptions(
              bar = list(
                colorByPoint = TRUE, # Enable coloring by point
                borderColor = "gold",
                opacity = 0.9
              )
            ) %>%
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
            highcharter::hc_legend(enabled = FALSE) %>% # Disable legend if not needed
            highcharter::hc_add_theme(
              highcharter::hc_theme(
                line = list(
                  color = "white"
                ),
                chart = list(
                  backgroundColor = "#222222"
                ),
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

          return(hcp)
        }
      })
    }
  )
}
