#' @title Ordered Bar Plot UI Module
#'
#' @description
#' A Shiny UI module for rendering a ggplot2-based Bar plot. This module generates
#' a plot output element that can be used to display a ggplot2 plot within a Shiny application.
#'
#' @param id A unique identifier for the module, used to distinguish this module's
#' UI and server components from others within a Shiny application.
#'
#'
#' @keywords internal
var_bar_ui <- function(id) {
  ns <- NS(id)
  plotOutput(outputId = ns("var_bar"))
}

#' @title Variance Bar Plot Server Module
#'
#' @description
#' A Shiny server module that renders a ggplot2-based bar plot representing the variance
#' explained by each principal component (PC). This module supports customization options
#' for titles, axis labels, and aesthetics such as bar width and transparency.
#'
#' @param id A unique identifier for the module, used to distinguish this module's
#' UI and server components from others within a Shiny application.
#' @param var_per_pc A numeric vector representing the variance explained by each
#' principal component (PC).
#' @param sd A numeric vector representing the standard deviation associated with
#' each principal component's variance.
#' @param main_title The main title of the plot.
#' @param x_label The label for the x-axis. Defaults to NULL.
#' @param y_label The label for the y-axis. Defaults to NULL.
#' @param sub_title An optional subtitle for the plot. Defaults to NULL.
#' @param bin_width The width of the bars in the plot. Defaults to 0.5.
#' @param bar_alpha The transparency level of the bars. Defaults to 0.7.
#' @param polar_cord A logical value indicating whether to use polar coordinates for the plot. Defaults to FALSE.
#'
#' @details
#' This module calculates the percentage of variance explained by each principal component
#' and generates a bar plot with error bars to indicate standard deviations. The plot is
#' rendered using ggplot2 with a minimalist theme and can be customized through various
#' parameters. It also includes options to display the percentage of variance on top of each bar.
#'
#' @keywords internal
var_bar_server <- function(id,
                           var_per_pc,
                           sd,
                           main_title,
                           x_label = NULL,
                           y_label = NULL,
                           sub_title = NULL,
                           bin_width = 0.5,
                           bar_alpha = 0.7,
                           polar_cord = FALSE) {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      df <- reactive({
        if (polar_cord) {
          x <- names(var_per_pc)
        } else {
          x <- paste0("PC", 1:length(var_per_pc))
        }
        percent_var <- (var_per_pc / sum(var_per_pc)) * 100

        df <- data.frame(
          percent_var = percent_var,
          x = x,
          sd = sd,
          var_per_pc = var_per_pc
        )
        return(df)
      })

      # Render a plot
      output$var_bar <- renderPlot({
        # Bar plot for Variance
        p <- ggplot() +
          theme_minimal() +
          labs(
            title = main_title,
            subtitle = sub_title,
            x = x_label,
            y = y_label
          ) +
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


        if (polar_cord) {
          p <- p +
            geom_bar(
              data = df(),
              aes(x = x, y = var_per_pc),
              stat = "identity", fill = "#21918c", color = "#f98e09",
              width = bin_width, alpha = bar_alpha
            ) + geom_text(
              data = df(),
              aes(
                x = x, y = var_per_pc,
                label = round(var_per_pc, 1),
              ), vjust = -1, size = 5,
              color = "#fcffa4"
            ) +
            coord_polar(theta = "x", clip = "off") + theme(
              axis.line.x = element_blank(),
              axis.line.y = element_blank(),
              axis.text.y = element_blank(),
              axis.ticks = element_blank(),
              axis.text.x = element_text(
                colour = "white", size = rel(1)
              ),
            ) +
            xlab("") + ylab("")
          return(p)
        } else {
          p <- p +
            geom_bar(
              data = df(),
              aes(x = factor(x, levels = paste0("PC", sort(as.numeric(gsub("PC", "", x))))), y = var_per_pc),
              stat = "identity", fill = "#21918c", color = "#f98e09",
              width = bin_width, alpha = bar_alpha
            ) +
            geom_errorbar(
              data = df(),
              aes(
                x = x, y = var_per_pc,
                ymin = var_per_pc - sd, ymax = var_per_pc + sd
              ), width = 0.3,
              alpha = 1, color = "#fde725", linetype = "dotted"
            ) + geom_text(
              data = df(),
              aes(
                x = x, y = var_per_pc,
                label = paste0(round(percent_var, 2), "%")
              ), vjust = -5,
              color = "#fcffa4"
            )
          return(p)
        }
      })
    }
  )
}
