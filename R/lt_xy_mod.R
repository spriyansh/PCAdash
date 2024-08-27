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
  plotOutput(outputId = ns("lt_xy"))
}

#' @title Longitudinal X-Y Plot Server Module
#'
#' @description
#' A Shiny server module that renders a ggplot2-based scatter plot to visualize
#' longitudinal data over time, with options for continuous or discrete color scaling.
#' This module supports customization of plot aesthetics such as point size, stroke,
#' and transparency, along with titles and axis labels.
#'
#' @param id A unique identifier for the module, used to distinguish this module's
#' UI and server components from others within a Shiny application.
#' @param x A numeric vector representing the x-axis data.
#' @param y A numeric vector representing the y-axis data.
#' @param pTime A numeric or datetime vector representing the progression or time data,
#' used for color mapping when \code{color_type} is set to "continuous".
#' @param main_title The main title of the plot.
#' @param x_label The label for the x-axis. Defaults to NULL.
#' @param y_label The label for the y-axis. Defaults to NULL.
#' @param sub_title An optional subtitle for the plot. Defaults to NULL.
#' @param catgeory A factor or character vector used for color mapping when \code{color_type}
#' is set to "discrete". Defaults to NULL.
#' @param cell_stroke The stroke width of the points. Defaults to 0.5.
#' @param cell_size The size of the points. Defaults to 2.
#' @param cell_alpha The transparency level of the points. Defaults to 0.6.
#' @param color_type A string specifying the type of color mapping. Options are "continuous"
#' (default) for mapping \code{pTime} to colors, or "discrete" for mapping \code{catgeory} to colors.
#'
#' @export
lt_xy_server <- function(id, x, y,
                         pTime,
                         main_title,
                         x_label = NULL,
                         y_label = NULL,
                         sub_title = NULL,
                         catgeory = NULL,
                         cell_stroke = reactive(0.5),
                         cell_size = reactive(2),
                         cell_alpha = reactive(0.6),
                         color_type = "contnious") {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      dicrete_cell_color <- "dicrete_cell_color"
      df <- reactive({
        df <- data.frame(
          x = x,
          y = y,
          catgeory = catgeory,
          pTime = pTime
        )

        if (color_type == "discrete") {
          df[["color_by"]] <- df[["catgeory"]]
        } else if (color_type == "contnious") {
          df[["color_by"]] <- df[["pTime"]]
        }

        return(df)
      })

      # Render a plot
      output$lt_xy <- renderPlot({
        p <- ggplot() +
          geom_point(
            data = df(), aes(x = x, y = y, color = .data$color_by),
            alpha = cell_alpha(), size = cell_size(), stroke = cell_stroke()
          ) +
          ggtitle(main_title,
            subtitle = sub_title
          ) +
          xlab(x_label) +
          ylab(y_label) +
          black_theme()

        if (color_type == "discrete") {
          p <- p + scale_color_manual(values = dicrete_cell_color)
        } else if (color_type == "contnious") {
          p <- p + scale_color_viridis_c(option = "magma")
        }

        return(p)
      })
    }
  )
}
