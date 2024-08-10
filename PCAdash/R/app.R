# # Load ggplot2
# library(ggplot2)
# library(PCAdash)
# # Dynamic Paramterers
# ## X-Y Plots
# data("pTime", package = "PCAdash")
# data("metagene_results", package = "PCAdash")
# data("cell_type", package = "PCAdash")
# data("tsne_coords", package = "PCAdash")
# data("counts", package = "PCAdash")
# data("pTime", package = "PCAdash")
# data("pTime", package = "PCAdash")
# metagene_id <- names(metagene_results)[8]
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
# tsne_coords <- tsne_coords[names(pTime), , drop = FALSE]
# tsne_x <- tsne_coords[, 1, drop = TRUE]
# tsne_y <- tsne_coords[, 2, drop = TRUE]
# y_matrix <- counts[rownames(metagene_results$`Oxidative phosphorylation`$loadings), , drop = FALSE]
#
# loading_vector <- metagene_results[[metagene_id]]$loadings[, 1]
#
# source("multi_ts_xy_mod.R")
# source("var_bar_mod.R")
# source("ts_xy_mod.R")
# source("lt_xy_mod.R")
# ui <- shiny::fluidPage(
#   shiny::fluidRow(
#     column(4, var_bar_ui("variance_bar")),
#     column(4, ts_xy_ui("metagene")),
#     column(4, lt_xy_ui("latent_plot")),
#   ),
#   shiny::fluidRow(
#     column(4, multi_ts_xy_ui("contri_genes")),
#     column(4, ts_xy_ui("contri_single")),
#     shiny::column(4, var_bar_ui("polar_bar"))
#   )
# )
#
# server <- function(input, output, session) {
#   source("multi_ts_xy_mod.R")
#   source("var_bar_mod.R")
#   source("ts_xy_mod.R")
#   source("lt_xy_mod.R")
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
#   lt_xy_server(
#     id = "latent_plot",
#     x = tsne_x,
#     y = tsne_y,
#     pTime = pTime,
#     main_title = main_title,
#     catgeory = color_by,
#     sub_title = "Latent Dimensions",
#     x_label = "tSNE-1",
#     y_label = "tSNE-2",
#     cell_alpha = 0.9,
#     cell_size = cell_size,
#     cell_stroke = 0.2,
#     color_type = "discrete"
#   )
#   multi_ts_xy_server(
#     id = "contri_genes",
#     x = x_values,
#     y_matrix = t(log1p(y_matrix)),
#     main_title = main_title,
#     color_by = color_by,
#     sub_title = sub_title,
#     x_label = x_label,
#     y_label = y_label,
#     trend_width = trend_width,
#     x_breaks = x_breaks,
#     cell_alpha = cell_alpha,
#     cell_size = cell_size,
#     cell_stroke = cell_stroke,
#     trend_alpha = 0.5
#   )
#   ts_xy_server(
#     id = "contri_single",
#     x = x_values,
#     y = t(log1p(y_matrix))[, 2, drop = TRUE],
#     main_title = main_title,
#     color_by = color_by,
#     sub_title = "Expression Pattern Over Pseudotime",
#     x_label = x_label,
#     y_label = "log1p(Expression)",
#     trend_width = trend_width,
#     x_breaks = x_breaks,
#     y_breaks = y_breaks,
#     cell_alpha = cell_alpha,
#     cell_size = cell_size,
#     cell_stroke = cell_stroke,
#     trend_alpha = trend_alpha
#   )
#
#   var_bar_server(
#     id = "polar_bar",
#     var_per_pc = loading_vector,
#     sd = sdev_per_pc,
#     main_title = metagene_id,
#     sub_title = "Loadings for Metagene",
#     x_label = "Principal Component",
#     y_label = "Variance Explained (%)",
#     bin_width = 0.5,
#     bar_alpha = 0.1,
#     polar_cord = TRUE
#   )
# }
# library(rhino)
# dicrete_cell_color <<- c("HSC" = "#56B4E9", "EMP" = "#F0E442", "Early Eryth" = "#009E73")
# options(shiny.autoreload = TRUE)
# shiny::shinyApp(ui = ui, server = server)
