#' @title Main App Server
#'
#' @description
#' Main Server of the App that contains all the modules.
#'
#' @param input Input from the UI
#' @param output Output to the UI
#' @param session Session of the App
#'
#' @export
app_server <- function(input, output, session) {
  # source(system.file("app/multi_ts_xy_mod.R", package = "YourPackage"))

  ts_xy_server(
    id = "metagene",
    x = x_values,
    y = y_values,
    main_title = main_title,
    color_by = color_by,
    sub_title = sub_title,
    x_label = x_label,
    y_label = y_label,
    trend_width = trend_width,
    x_breaks = x_breaks,
    y_breaks = y_breaks,
    cell_alpha = cell_alpha,
    cell_size = cell_size,
    cell_stroke = cell_stroke,
    trend_alpha = trend_alpha
  )

  var_bar_server(
    id = "variance_bar",
    var_per_pc = var_per_pc,
    sd = sdev_per_pc,
    main_title = metagene_id,
    sub_title = "Variance Explained Per PC",
    x_label = "Principal Component",
    y_label = "Variance Explained (%)",
    bin_width = 0.5,
    bar_alpha = 0.1
  )

  lt_xy_server(
    id = "latent_plot",
    x = tsne_x,
    y = tsne_y,
    pTime = pTime,
    main_title = main_title,
    catgeory = color_by,
    sub_title = "Latent Dimensions",
    x_label = "tSNE-1",
    y_label = "tSNE-2",
    cell_alpha = 0.9,
    cell_size = cell_size,
    cell_stroke = 0.2,
    color_type = "discrete"
  )

  multi_ts_xy_server(
    id = "contri_genes",
    x = x_values,
    y_matrix = t(log1p(y_matrix)),
    main_title = main_title,
    color_by = color_by,
    sub_title = sub_title,
    x_label = x_label,
    y_label = y_label,
    trend_width = trend_width,
    x_breaks = x_breaks,
    cell_alpha = cell_alpha,
    cell_size = cell_size,
    cell_stroke = cell_stroke,
    trend_alpha = 0.5
  )

  ts_xy_server(
    id = "contri_single",
    x = x_values,
    y = t(log1p(y_matrix))[, 2, drop = TRUE],
    main_title = main_title,
    color_by = color_by,
    sub_title = "Expression Pattern Over Pseudotime",
    x_label = x_label,
    y_label = "log1p(Expression)",
    trend_width = trend_width,
    x_breaks = x_breaks,
    y_breaks = y_breaks,
    cell_alpha = cell_alpha,
    cell_size = cell_size,
    cell_stroke = cell_stroke,
    trend_alpha = trend_alpha
  )
  var_bar_server(
      id = "polar_bar",
      var_per_pc = loading_vector,
      sd = sdev_per_pc,
      main_title = metagene_id,
      sub_title = "Loadings for Metagene",
      x_label = "Principal Component",
      y_label = "Variance Explained (%)",
      bin_width = 0.5,
      bar_alpha = 0.1,
      polar_cord = TRUE
  )
}
