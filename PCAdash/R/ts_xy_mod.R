#' @title X-Y Plot UI Module
#'
#' @description
#' A Shiny UI module for rendering a ggplot2-based X-Y plot. This module generates
#' a plot output element that can be used to display a ggplot2 plot within a Shiny application.
#'
#' @param id A unique identifier for the module, used to distinguish this module's
#' UI and server components from others within a Shiny application.
#'
#' @import ggplot2
#' @import shiny
#'
#' @export
ts_xy_ui <- function(id) {
  ns <- NS(id)
  plotOutput(outputId = ns("ts_xy"))
}

#' @title X-Y Plot Server Module
#'
#' @description
#' A Shiny server module that handles the rendering of a ggplot2-based X-Y plot.
#' This module accepts x and y values as inputs and provides various customization
#' options for rendering a detailed line plot with trend lines, titles, axis labels,
#' and aesthetic customizations.
#'
#' @param id A unique identifier for the module, used to distinguish this module's
#' UI and server components from others within a Shiny application.
#' @param x A numeric vector representing the x-axis data.
#' @param y A numeric vector representing the y-axis data.
#' @param main_title The main title of the plot.
#' @param x_label The label for the x-axis.
#' @param y_label The label for the y-axis.
#' @param sub_title An optional subtitle for the plot.
#' @param color_by A factor or character vector for coloring the points by a category.
#' @param trend_width The width of the trend line.
#' @param x_breaks The interval for breaks on the x-axis.
#' @param y_breaks The interval for breaks on the y-axis.
#' @param cell_stroke The stroke width of the points.
#' @param cell_size The size of the points.
#' @param cell_alpha The transparency level of the points.
#' @param trend_alpha The transparency level of the trend line.
#'
#' @import ggplot2
#' @import shiny
#'
#' @export
ts_xy_server <- function(id, x, y, main_title, x_label = NULL,
                         y_label = NULL, sub_title = NULL, color_by = NULL,
                         trend_width = 2, x_breaks = 5,
                         y_breaks = 1,
                         cell_stroke = 0.5, cell_size = 2, cell_alpha = 0.6,
                         trend_alpha = 0.8) {
  dicrete_cell_color <<- c("HSC" = "#56B4E9", "EMP" = "#F0E442", "Early Eryth" = "#009E73")
  moduleServer(
    id = id,
    module = function(input, output, session) {
      df <- reactive({
        data.frame(
          x = x,
          y = y,
          color_by = color_by
        )
      })

      # Render a plot
      output$ts_xy <- renderPlot({
        ggplot() +
          geom_point(
            data = df(), aes(x = x, y = y, color = color_by),
            alpha = cell_alpha, size = cell_size, stroke = cell_stroke
          ) +
          geom_smooth(
            data = df(), aes(x = x, y = y),
            method = "gam", formula = y ~ s(x, bs = "cs"),
            se = FALSE, linewidth = trend_width, color = "#e84258",
            alpha = trend_alpha
          ) +
          ggtitle(main_title,
            subtitle = sub_title
          ) +
          xlab(x_label) +
          ylab(y_label) +
          theme_linedraw() +
          theme(
            panel.border = element_blank(),
            panel.background = element_blank(),
            plot.background = element_rect(color = "#222222", fill = "#222222"),
            plot.title = element_text(color = "white", size = rel(1.5)),
            plot.subtitle = element_text(color = "white", size = rel(1.5)),
            panel.grid.major = element_line(linewidth = rel(0.1), linetype = 2, colour = "#f6f6f6"),
            panel.grid.minor = element_blank(),
            axis.text = element_text(colour = "white", size = rel(1.2)),
            axis.line.x = element_line(arrow = arrow(
              angle = 15, length = unit(0.5, "cm"),
              ends = "last", type = "closed"
            ), colour = "white"),
            axis.line.y = element_line(arrow = arrow(
              angle = 15, length = unit(0.5, "cm"),
              ends = "last", type = "closed"
            ), colour = "white"),
            axis.ticks = element_line(colour = "white"),
            axis.title = element_text(color = "white", size = rel(1.25)),
            legend.position = "none"
          ) +
          scale_color_manual(values = dicrete_cell_color) +
          scale_x_continuous(
            limits = c(0, max(df()[["x"]])) + 1.5,
            breaks = round(seq(0, max(df()[["x"]]) + x_breaks, by = x_breaks))
          ) +
          scale_y_continuous(
            limits = c(min(df()[["y"]]), max(df()[["y"]]) + 1.5),
            breaks = round(seq(min(df()[["y"]]), max(df()[["y"]]) + y_breaks, by = y_breaks), 1)
          )
      })
    }
  )
}
