#' @title Run PCAdash App
#'
#' @description ABC
#'
#' @import ggplot2
#' @import shiny
#' @importFrom utils data
#'
#' @author Priyansh Srivastava
#'
#' @export
run_app <- function() {
  # Dynamic Paramterers
  ## X-Y Plots
  data("pTime", package = "PCAdash")
  data("metagene_results", package = "PCAdash")
  data("cell_type", package = "PCAdash")
  data("tsne_coords", package = "PCAdash")
  data("counts", package = "PCAdash")
  data("pTime", package = "PCAdash")
  data("pTime", package = "PCAdash")
  metagene_id <<- "Oxidative phosphorylation"
  x_values <<- pTime
  y_values <<- as.numeric(metagene_results[[metagene_id]]$PC)
  main_title <<- metagene_results[[metagene_id]]$term
  sub_title <<- "Metagene Over Pseudotime"
  color_by <<- cell_type
  x_label <<- "Pseudotime"
  y_label <<- "Metagene Trend"
  trend_width <<- 2
  x_breaks <<- 4
  y_breaks <<- 2
  cell_alpha <<- 0.4
  cell_size <<- 4
  cell_stroke <<- 0
  trend_alpha <<- 1
  var_per_pc <<- metagene_results[[metagene_id]]$variance_per_pc
  percentage_var_per_pc <<- (var_per_pc / sum(var_per_pc)) * 100
  sdev_per_pc <<- sqrt(var_per_pc)
  tsne_coords <<- tsne_coords[names(pTime), , drop = FALSE]
  tsne_x <<- tsne_coords[, 1, drop = TRUE]
  tsne_y <<- tsne_coords[, 2, drop = TRUE]
  y_matrix <<- counts[rownames(metagene_results$`Oxidative phosphorylation`$loadings), , drop = FALSE]

  shiny::shinyApp(ui = app_ui(), server = app_server)
}
