function(input, output, session) {
  # Initialize reactiveVal for metagene_id
  metagene_id <- reactiveVal(NULL)
  gene_list <- reactiveVal(NULL)

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
        metagene_id(pathway_list[2])
      } else {
        metagene_id(selected_pathway)
      }

      loadings <- metagene_results[[metagene_id()]]$loadings
      y <- rownames(loadings)
      names(y) <- y
      gene_list(y)
    },
    ignoreInit = TRUE
  )

  observe({
    updateSelectInput(
      session,
      inputId = "gene_select",
      choices = gene_list(),
      selected = gene_list()[2] # Access gene_list as a function to get its contents
    )
  })


  # source("/home/priyansh/gitDockers/PCAdash/R/dynamic_controls.R")
  vis_params_metagene <- vis_params_server("vis_params_metagene",
    plot_type = reactive(input$plot_select),
    max_bar_pc = reactive(
      length(metagene_results[[metagene_id()]]$variance_per_pc)
    )
  )
  vis_params_polar <- vis_params_server("vis_params_polar",
    plot_type = reactive(input$plot_select),
    max_bar_pc = reactive(
      length(metagene_results[[metagene_id()]]$variance_per_pc)
    )
  )

  vis_params_latent <- vis_params_server("vis_params_latent",
    plot_type = reactive(input$plot_select),
    max_bar_pc = reactive(
      length(metagene_results[[metagene_id()]]$variance_per_pc)
    )
  )
  vis_params_contri <- vis_params_server("vis_params_contri",
    plot_type = reactive(input$plot_select),
    max_bar_pc = reactive(
      length(metagene_results[[metagene_id()]]$variance_per_pc)
    )
  )
  vis_params_contri_single <- vis_params_server("vis_params_contri_single",
    plot_type = reactive(input$plot_select),
    max_bar_pc = reactive(
      length(metagene_results[[metagene_id()]]$variance_per_pc)
    )
  )


  # Dynamically render the UI for the correct plot type
  output$dynamic_vis_params_ui <- renderUI({
    if (input$plot_select %in% c("metagene", "variance_bar")) {
      vis_params_ui("vis_params_metagene")
    } else if (input$plot_select == "latent_plot") {
      vis_params_ui("vis_params_latent")
    } else if (input$plot_select == "contri_features") {
      vis_params_ui("vis_params_contri")
    } else if (input$plot_select == "contri_features_single") {
      vis_params_ui("vis_params_contri_single")
    } else if (input$plot_select == "variance_polar") {
      vis_params_ui("vis_params_polar")
    } else {
      print("No matching plot type found")
    }
  })


  # source("/home/priyansh/gitDockers/PCAdash/R/ts_xy_mod.R")
  ts_xy_server(
    id = "metagene",
    x = pTime,
    y = reactive({
      req(metagene_id())
      as.numeric(metagene_results[[as.character(metagene_id())]]$PC)
    }),
    main_title = "A",
    color_by = "cell_type",
    sub_title = "Metagene Over Pseudotime",
    x_label = "Monocle3 Pseudotime",
    y_label = "Metagene Trend",
    cell_alpha = vis_params_metagene$cell_alpha,
    cell_size = vis_params_metagene$cell_size,
    cell_stroke = vis_params_metagene$cell_stroke,
    trend_width = vis_params_metagene$trend_width
  )

  # source("/home/priyansh/gitDockers/PCAdash/R/var_bar_mod.R")
  var_bar_server(
    id = "variance_bar",
    var_per_pc = reactive({
      req(metagene_id())
      metagene_results[[metagene_id()]][["variance_per_pc"]]
    }),
    sd = reactive({
      req(metagene_id())
      sqrt(metagene_results[[metagene_id()]][["variance_per_pc"]])
    }),
    main_title = "A",
    sub_title = "Variance Explained Per PC",
    x_label = "Principal Component",
    y_label = "Variance Explained (%)",
    bin_width = vis_params_metagene$bar_width,
    bar_alpha = vis_params_metagene$bar_alpha,
    n_bar = vis_params_metagene$n_pcs
  )

  var_bar_server(
    id = "polar_bar",
    var_per_pc = reactive({
      req(metagene_id())
      loading_vector <- metagene_results[[metagene_id()]][["loadings"]]
      loading_vector <- loading_vector[, 1, drop = TRUE]
      names(loading_vector) <- rownames(metagene_results[[metagene_id()]][["loadings"]])
      return(loading_vector)
    }),
    sd = reactive({
      req(metagene_id())
      sqrt(metagene_results[[metagene_id()]][["variance_per_pc"]])
    }),
    main_title = "A",
    sub_title = "Loadings for Metagene",
    x_label = "Principal Component",
    y_label = "Variance Explained (%)",
    bin_width = vis_params_polar$bar_width,
    bar_alpha = vis_params_polar$bar_alpha,
    polar_cord = TRUE
  )

  # source("/home/priyansh/gitDockers/PCAdash/R/lt_xy_mod.R")
  lt_xy_server(
    id = "latent_plot",
    x = tsne_coords[, 1, drop = FALSE],
    y = tsne_coords[, 2, drop = FALSE],
    pTime = pTime,
    main_title = "A",
    catgeory = cell_type,
    sub_title = "Latent Dimensions",
    x_label = "tSNE-1",
    y_label = "tSNE-2",
    cell_alpha = vis_params_latent$cell_alpha,
    cell_size = vis_params_latent$cell_size,
    cell_stroke = vis_params_latent$cell_stroke,
    color_type = "contnious"
  )

  # source("/home/priyansh/gitDockers/PCAdash/R/multi_ts_xy_mod.R")
  multi_ts_xy_server(
    id = "contri_genes",
    x = pTime,
    y_matrix =
      reactive({
        req(metagene_id())
        y_matrix <- t(log1p(counts[, names(pTime), drop = FALSE]))
        y_matrix <- y_matrix[, rownames(metagene_results[[metagene_id()]][["loadings"]]), drop = FALSE]
        return(y_matrix)
      }),
    main_title = "A",
    color_by = cell_type,
    trend_width = vis_params_contri$trend_width,
    cell_alpha = vis_params_contri$cell_alpha,
    cell_size = vis_params_contri$cell_size,
    cell_stroke = vis_params_contri$cell_stroke,
    trend_alpha = vis_params_contri$trend_alpha
  )



  ts_xy_server(
    id = "contri_single",
    x = pTime,
    y = reactive({
      req(metagene_id())
      req(input$gene_select)
      return(log1p(counts[input$gene_select, , drop = TRUE]))
    }),
    main_title = "A",
    color_by = cell_type,
    sub_title = "Expression Pattern Over Pseudotime",
    y_label = "log1p(Expression)",
    trend_width = vis_params_contri_single$trend_width,
    cell_alpha = vis_params_contri_single$cell_alpha,
    cell_size = vis_params_contri_single$cell_size,
    cell_stroke = vis_params_contri_single$cell_stroke
  )
}
