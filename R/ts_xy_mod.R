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
#'
#' @import ggplot2
#'
#' @importFrom stats complete.cases
#'
#' @export
ts_xy_server <- function(id,
                         x,
                         y,
                         main_title = "Main Title",
                         x_label = "x_lable",
                         y_label = "y_lable",
                         sub_title = "Sub Title",
                         color_by = NULL,
                         trend_width = reactive(2),
                         x_breaks = reactive(5),
                         y_breaks = reactive(1),
                         cell_stroke = reactive(0.5),
                         cell_size = reactive(2),
                         cell_alpha = reactive(0.6)) {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      df <- reactive({
        # Construct data frame
        d <- data.frame(
          x = x,
          y = y(),
          color_by = color_by
        )

        # Remove rows with missing values
        d <- d[complete.cases(d), ]

        # Return
        return(d)
      })

      # Render a plot
      output$ts_xy <- renderPlot({
        p <- ggplot() +
          geom_point(
            data = df(), aes(x = .data$x, y = .data$y, color = .data$color_by),
            alpha = cell_alpha(),
            size = cell_size(),
            stroke = cell_stroke()
          ) +
          geom_smooth(
            data = df(), aes(x = .data$x, y = .data$y),
            method = "gam", formula = y ~ s(x, bs = "cs"),
            se = FALSE,
            linewidth = trend_width(),
            color = "#F0E442"
          ) +
          ggtitle(main_title,
            subtitle = sub_title
          ) +
          xlab(x_label) +
          ylab(y_label) +
          black_theme() #+
        # scale_color_manual(values = dicrete_cell_color) +
        # scale_x_continuous(
        #   limits = c(0, max(df()[["x"]])) + 1.5,
        #   breaks = round(seq(0, max(df()[["x"]]) + x_breaks, by = x_breaks))
        # ) +
        # scale_y_continuous(
        #   limits = c(min(df()[["y"]]), max(df()[["y"]]) + 1.5),
        #   breaks = round(seq(min(df()[["y"]]), max(df()[["y"]]) + y_breaks, by = y_breaks), 1)
        # )
        return(p)
      })
    }
  )
}
