function(input, output, session) {
  # Initialize reactiveVal for metagene_id
  metagene_id <- reactiveVal(NULL)

  # Load the metagene results and prepare pathway list
  pathway_list <- names(metagene_results)
  names(pathway_list) <- pathway_list

  # Update the selectInput with the pathway lists
  updateSelectInput(
    session,
    inputId = "pathway_select",
    choices = pathway_list,
    selected = pathway_list[2]
  )

  # Observe changes in pathway_select input and update metagene_id accordingly
  observeEvent(input$pathway_select,
    {
      selected_pathway <- input$pathway_select
      if (is.null(selected_pathway) || selected_pathway == "") {
        metagene_id(pathway_list[2]) # Default to second pathway if none selected
      } else {
        metagene_id(selected_pathway)
      }
    },
    ignoreInit = TRUE
  )

  # bump -3

  # Pass data to ts_xy_server module
  source("/home/priyansh/gitDockers/PCAdash/R/ts_xy_mod.R")
  ts_xy_server(
    id = "metagene",
    x = pTime,
    y = reactive({
      # Ensure metagene_id() is not NULL before accessing metagene_results
      req(metagene_id())
      as.numeric(metagene_results[[as.character(metagene_id())]]$PC)
    }),
    main_title = "A", # Make main_title reactive
    color_by = "cell_type",
    sub_title = "Metagene Over Pseudotime",
    x_label = "Monocle3 Pseudotime",
    y_label = "Metagene Trend",
    cell_alpha = reactive(as.numeric(input$cell_alpha)),
    cell_size = reactive(as.numeric(input$cell_size)),
    cell_stroke = reactive(as.numeric(input$cell_stroke)),
    trend_width = reactive(as.numeric(input$trend_width))
  )
  #
  # ss###s sssWssass
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
  #
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
  #
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
  #
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
}
