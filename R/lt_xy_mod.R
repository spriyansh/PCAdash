#' @title Latent Dimenions X-Y Plot UI Module
#'
#' @description
#' A Shiny UI module for rendering a ggplot2-based X-Y plot for latent Dimensions.
#' This module generates a plot output element that can be used to display a ggplot2 plot within a Shiny application.
#'
#' @param id A unique identifier for the module, used to distinguish this module's
#' UI and server components from others within a Shiny application.
#'
#' @keywords internal
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
#' @keywords internal
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
  color_by <- "color_by"
  dicrete_cell_color <<- c("HSC" = "#56B4E9", "EMP" = "#F0E442", "Early Eryth" = "#009E73")

  moduleServer(
    id = id,
    module = function(input, output, session) {
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
            data = df(), aes(x = x, y = y, color = color_by),
            alpha = cell_alpha(), size = cell_size(), stroke = cell_stroke()
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
          )

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
