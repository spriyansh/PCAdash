#' @title Ordered Bar Plot UI Module
#'
#' @description
#' A Shiny UI module for rendering a ggplot2-based Bar plot.
#'
#' @param id A unique identifier for the module.
#'
#'
#' @export
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
#' @param n_bar The number of bars to display in the plot. Defaults to 5.
#' @param main_title The main title of the plot.
#' @param x_label The label for the x-axis. Defaults to NULL.
#' @param y_label The label for the y-axis. Defaults to NULL.
#' @param sub_title An optional subtitle for the plot. Defaults to NULL.
#' @param bin_width The width of the bars in the plot. Defaults to 0.5.
#' @param bar_alpha The transparency level of the bars. Defaults to 0.7.
#' @param polar_cord A logical value indicating whether to use polar coordinates for the plot. Defaults to FALSE.
#' @param activate_legend A logical value indicating whether to activate the legend. Defaults to FALSE.
#'
#' @export
var_bar_server <- function(id,
                           var_per_pc,
                           sd,
                           n_bar = reactive(5),
                           main_title,
                           x_label = NULL,
                           y_label = NULL,
                           sub_title = NULL,
                           bin_width = reactive(0.5),
                           bar_alpha = reactive(0.7),
                           polar_cord = FALSE,
                           activate_legend = reactive(FALSE)) {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      dicrete_cell_color <- "dicrete_cell_color"
      df <- reactive({
        if (polar_cord) {
          x <- names(var_per_pc())
        } else {
          x <- paste0("PC", 1:length(var_per_pc()))
        }
        percent_var <- (var_per_pc() / sum(var_per_pc())) * 100

        df <- data.frame(
          percent_var = percent_var,
          x = x,
          sd = sd(),
          var_per_pc = var_per_pc()
        )
        return(df)
      })

      # Render a plot
      output$var_bar <- renderPlot({
        # Bar plot for Variance
        p <- ggplot() +
          labs(
            title = main_title,
            subtitle = sub_title,
            x = x_label,
            y = y_label
          ) +
          black_theme(activate = activate_legend())

        if (polar_cord) {
          p <- p +
            geom_bar(
              data = df()[c(1:n_bar()), , drop = FALSE],
              aes(x = x, y = var_per_pc, fill = var_per_pc > 0),
              stat = "identity", color = "#f98e09",
              width = bin_width(), alpha = bar_alpha()
            ) +
            geom_text(
              data = df()[c(1:n_bar()), , drop = FALSE],
              aes(
                x = x, y = var_per_pc,
                label = round(var_per_pc, 1)
              ), vjust = ifelse(df()[c(1:n_bar()), , drop = FALSE]$var_per_pc >= 0, -0.5, 1.5), size = 5,
              color = "#fcffa4"
            ) +
            scale_fill_manual(values = c("#21918c", "#f98e09")) +
            theme(
              axis.line.x = element_blank(),
              axis.line.y = element_blank(),
              axis.text.y = element_blank(),
              axis.ticks = element_blank(),
              axis.text.x = element_text(
                colour = "white", size = rel(1)
              ),
              legend.position = "none"
            ) +
            coord_flip() +
            xlab("") + ylab("") + theme_void() + black_theme(
              activate = activate_legend()
            )
          return(p)
        } else {
          p <- p +
            geom_bar(
              data = df()[c(1:n_bar()), , drop = FALSE],
              aes(x = factor(x, levels = paste0("PC", sort(as.numeric(gsub("PC", "", x))))), y = var_per_pc),
              stat = "identity", fill = "#21918c", color = "#f98e09",
              width = bin_width(), alpha = bar_alpha()
            ) +
            geom_errorbar(
              data = df()[c(1:n_bar()), , drop = FALSE],
              aes(
                x = x, y = var_per_pc,
                ymin = var_per_pc - sd, ymax = var_per_pc + sd
              ), width = 0.3,
              alpha = 1, color = "#fde725", linetype = "dotted"
            ) + geom_text(
              data = df()[c(1:n_bar()), , drop = FALSE],
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


#
# library(highcharter)
# pc_info <- data.table::fread(
#     file = "inst/app/www/data/pc_info_s3.txt",
#     sep = "\t", header = TRUE,
#     data.table = TRUE,
#     select = c(1:4),
#     stringsAsFactors = FALSE
# )
# pc_info <- pc_info[pc_info$path_id == "hsa00590", c("pc", "variance_explained", "sd"),drop=FALSE]
# main_title ="Variance Explained Per PC"
# sub_title =NULL
# x_label = "Principal Components"
# y_label = "Variance Explained (%)"
# hchart(
#     pc_info,
#     "column",
#     hcaes(x = pc, y = round(variance_explained, 3)),
# ) %>%
#     hc_add_series(
#         pc_info,
#         "errorbar",
#         hcaes(y = variance_explained, x = pc, low = variance_explained - sd, high = variance_explained + sd),
#         enableMouseTracking = TRUE,
#         showInLegend = FALSE
#     ) %>%
#     hc_plotOptions(
#         errorbar = list(
#             color = "#fde725",
#             # whiskerLength = 1,
#             stemWidth = 1
#         ),
#         column = list(
#             color = "#21918c",
#             borderColor = "#f98e09",
#             opacity = 0.7
#         )
#     )%>%
#     highcharter::hc_title(text = main_title, style = list(color = "white")) %>%
#     highcharter::hc_subtitle(text = sub_title, style = list(color = "white")) %>%
#     highcharter::hc_xAxis(
#         title = list(
#             text = x_label,
#             style = list(color = "white")
#         ),
#         lineColor = "white",
#         lineWidth = 2,
#         gridLineWidth = 0,
#         labels = list(style = list(color = "white"))
#     ) %>%
#     highcharter::hc_yAxis(
#         title = list(
#             text = y_label,
#             style = list(color = "white")
#         ),
#         lineColor = "white",
#         lineWidth = 2,
#         gridLineWidth = 0,
#         labels = list(style = list(color = "white"))
#     ) %>%
#     highcharter::hc_legend(enabled = TRUE) %>%
#     highcharter::hc_add_theme(
#         highcharter::hc_theme(
#             line = list(
#                 color = "white"
#             ),
#             chart = list(
#                 backgroundColor = "#222222"
#             ),
#             # Remove colors from the theme to prevent overriding
#             # colors = colors,
#             title = list(
#                 style = list(
#                     color = "white",
#                     fontFamily = "Times",
#                     fontSize = "25px"
#                 )
#             ),
#             subtitle = list(
#                 style = list(
#                     color = "white",
#                     fontFamily = "Times",
#                     fontSize = "15px"
#                 )
#             ),
#             legend = list(
#                 itemStyle = list(
#                     fontFamily = "Times",
#                     color = "white"
#                 ),
#                 itemHoverStyle = list(
#                     color = "yellow"
#                 )
#             )
#         ))
