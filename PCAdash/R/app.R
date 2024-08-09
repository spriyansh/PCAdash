# # Load ggplot2
# library(ggplot2)
# library(PCAdash)
#
# var_bar_ui <- function(id) {
#   ns <- NS(id)
#   plotOutput(outputId = ns("var_bar"))
# }
#
#
#
# var_bar <- function(id, x, y, main_title, x_label = NULL,
#                     y_label = NULL, sub_title = NULL, color_by = NULL,
#                     trend_width = 2, x_breaks = 5,
#                     y_breaks = 1,
#                     cell_stroke = 0.5, cell_size = 2, cell_alpha = 0.6,
#                     trend_alpha = 0.8) {
#   moduleServer(
#     id = id,
#     module = function(input, output, session) {
#       df <- reactive({
#         data.frame(
#           x = x,
#           y = y,
#           color_by = color_by
#         )
#       })
#
#       # Render a plot
#       output$ts_xy <- renderPlot({
#         ggplot() +
#           geom_point(
#             data = df(), aes(x = x, y = y, color = color_by),
#             alpha = cell_alpha, size = cell_size, stroke = cell_stroke
#           ) +
#           geom_smooth(
#             data = df(), aes(x = x, y = y),
#             method = "gam", formula = y ~ s(x, bs = "cs"),
#             se = FALSE, linewidth = trend_width, color = "#e84258",
#             alpha = trend_alpha
#           ) +
#           ggtitle(main_title,
#             subtitle = sub_title
#           ) +
#           xlab(x_label) +
#           ylab(y_label) +
#           theme_linedraw() +
#           theme(
#             panel.border = element_blank(),
#             panel.background = element_blank(),
#             plot.background = element_rect(color = "#222222", fill = "#222222"),
#             plot.title = element_text(color = "white", size = rel(1.5)),
#             plot.subtitle = element_text(color = "white", size = rel(1.5)),
#             panel.grid.major = element_line(linewidth = rel(0.1), linetype = 2, colour = "#f6f6f6"),
#             panel.grid.minor = element_blank(),
#             axis.text = element_text(colour = "white", size = rel(1.2)),
#             axis.line.x = element_line(arrow = arrow(
#               angle = 15, length = unit(0.5, "cm"),
#               ends = "last", type = "closed"
#             ), colour = "white"),
#             axis.line.y = element_line(arrow = arrow(
#               angle = 15, length = unit(0.5, "cm"),
#               ends = "last", type = "closed"
#             ), colour = "white"),
#             axis.ticks = element_line(colour = "white"),
#             axis.title = element_text(color = "white", size = rel(1.25)),
#             legend.position = "none"
#           ) +
#           scale_color_manual(values = c("HSC" = "#56B4E9", "EMP" = "#F0E442", "Early Eryth" = "#009E73")) +
#           scale_x_continuous(
#             limits = c(0, max(df()[["x"]])) + 1.5,
#             breaks = round(seq(0, max(df()[["x"]]) + x_breaks, by = x_breaks))
#           ) +
#           scale_y_continuous(
#             limits = c(min(df()[["y"]]), max(df()[["y"]]) + 1.5),
#             breaks = round(seq(min(df()[["y"]]), max(df()[["y"]]) + y_breaks, by = y_breaks), 1)
#           )
#       })
#     }
#   )
# }
#
#
# # Dynamic Paramterers
# ## X-Y Plots
# data("pTime", package = "PCAdash")
# data("metagene_results", package = "PCAdash")
# data("cell_type", package = "PCAdash")
# data("pTime", package = "PCAdash")
# data("pTime", package = "PCAdash")
# data("pTime", package = "PCAdash")
# data("pTime", package = "PCAdash")
# metagene_id <- "Oxidative phosphorylation"
# x_values <- pTime
# y_values <- as.numeric(metagene_results[[metagene_id]]$PC)
# main_title <- metagene_results[[metagene_id]]$term
# sub_title <- "Metagene Over Pseudotime"
# color_by <- cell_type
# x_label <- "Pseudotime"
# y_label <- "Metagene Trend"
# trend_width <- 2
# x_breaks <- 4
# y_breaks <- 2
# cell_alpha <- 0.4
# cell_size <- 4
# cell_stroke <- 0
# trend_alpha <- 1
# var_per_pc <- metagene_results[[metagene_id]]$variance_per_pc
# percentage_var_per_pc <- (var_per_pc / sum(var_per_pc)) * 100
# sdev_per_pc <- sqrt(var_per_pc)
#
#
# ui <- shiny::fluidPage(
#   shiny::fluidRow(
#     var_bar_ui("variance_bar"),
#     ts_xy_ui("metagene")
#   )
# )
#
#
# server <- function(input, output, session) {
#   ts_xy_server(
#     id = "metagene",
#     x = x_values,
#     y = y_values,
#     main_title = main_title,
#     color_by = color_by,
#     sub_title = sub_title,
#     x_label = x_label,
#     y_label = y_label,
#     trend_width = trend_width,
#     x_breaks = x_breaks,
#     y_breaks = y_breaks,
#     cell_alpha = cell_alpha,
#     cell_size = cell_size,
#     cell_stroke = cell_stroke,
#     trend_alpha = trend_alpha
#   )
#   var_bar_server(
#     id = "variance_bar",
#     var_per_pc = var_per_pc,
#     sd = sdev_per_pc,
#     main_title = metagene_id,
#     sub_title = "Variance Explained Per PC",
#     x_label = "Principal Component",
#     y_label = "Variance Explained (%)",
#     bin_width = 0.5,
#     bar_alpha = 0.1
#   )
# }
# library(rhino)
# options(shiny.autoreload = TRUE)
# shiny::shinyApp(ui = ui, server = server)
