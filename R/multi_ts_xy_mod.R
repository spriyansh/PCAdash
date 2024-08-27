#' @title Multi X-Y Plot UI Module
#'
#' @description
#' A Shiny UI module for rendering a ggplot2-based X-Y plot.
#'
#' @param id A unique identifier for the module.
#'
#' @export
multi_ts_xy_ui <- function(id) {
  ns <- NS(id)
  plotOutput(outputId = ns("multi_ts_xy"))
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
#' @param y_matrix A matrix of y values representing the y-axis data.
#' @param main_title The main title of the plot.
#' @param x_label The label for the x-axis.
#' @param y_label The label for the y-axis.
#' @param sub_title An optional subtitle for the plot.
#' @param color_by A factor or character vector for coloring the points by a category.
#' @param trend_width The width of the trend line.
#' @param x_breaks The interval for breaks on the x-axis.
#' @param cell_stroke The stroke width of the points.
#' @param cell_size The size of the points.
#' @param cell_alpha The transparency level of the points.
#' @param trend_alpha The transparency level of the trend line.
#'
#' @import ggplot2
#' @import shiny
#'
#' @export
multi_ts_xy_server <- function(id,
                               x,
                               y_matrix,
                               main_title = "Main-title",
                               x_label = "x-label",
                               y_label = "y-label",
                               sub_title = "Sub-title",
                               color_by,
                               trend_width = reactive(2),
                               x_breaks = reactive(5),
                               cell_stroke = reactive(0.5),
                               cell_size = reactive(2),
                               cell_alpha = reactive(0.6),
                               trend_alpha = reactive(0.8)) {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      dicrete_cell_color <- "dicrete_cell_color"
      df <- reactive({
        df <- data.frame(
          x = x,
          color_by = color_by
        )
        df <- cbind(df, y_matrix())

        return(df)
      })

      # Render a plot
      output$multi_ts_xy <- renderPlot({
        p <- ggplot()

        for (i in colnames(y_matrix())) {
          p <- p + geom_smooth(
            data = df(), aes(x = .data$x, y = .data[[i]]),
            method = "gam", formula = y ~ s(x, bs = "cs"),
            se = FALSE, linewidth = trend_width(), color = "#fde725",
            linetype = "solid"
          )
        }
        p <- p + ggtitle(main_title,
          subtitle = sub_title
        ) +
          xlab(x_label) +
          ylab(y_label) +
          black_theme()
        return(p)
        # scale_y_continuous(
        #     limits = c(min(df()[["y"]]), max(df()[["y"]]) + 1.5),
        #     breaks = round(seq(min(df()[["y"]]), max(df()[["y"]]) + y_breaks, by = y_breaks), 1)
        # )
      })
    }
  )
}
