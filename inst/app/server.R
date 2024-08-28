function(input, output, session) {
  # source("/home/priyansh/gitDockers/PCAdash/R/dynamic_control_mod.R")
  # source("/home/priyansh/gitDockers/PCAdash/R/ts_xy_mod.R")
  # source("/home/priyansh/gitDockers/PCAdash/R/lt_xy_mod.R")
  # source("/home/priyansh/gitDockers/PCAdash/R/multi_ts_xy_mod.R")
  # source("/home/priyansh/gitDockers/PCAdash/R/zzz.R")

  # Initialize reactiveVal for metagene_id
  metagene_id <- reactiveVal(NULL)
  gene_list <- reactiveVal(NULL)
  activate_legend <- reactiveVal(FALSE)


  # Load the metagene results and prepare pathway lists
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

  observeEvent(input$plot_select, {
    if (input$plot_select == "metagene") {
      activate_legend(TRUE)
    } else if (input$plot_select == "variance_bar") {
      activate_legend(TRUE)
    } else if (input$plot_select == "latent_plot") {
      activate_legend(TRUE)
    } else if (input$plot_select == "contri_features") {
      activate_legend(TRUE)
    } else if (input$plot_select == "contri_features_single") {
      activate_legend(TRUE)
    } else if (input$plot_select == "variance_polar") {
      activate_legend(TRUE)
    } else {
      activate_legend(FALSE)
    }
  })


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


  ts_xy_server(
    id = "metagene",
    x = pTime,
    y = reactive({
      req(metagene_id())
      as.numeric(metagene_results[[as.character(metagene_id())]]$PC)
    }),
    main_title = "Metagene Over Pseudotime",
    color_by = "cell_type",
    sub_title = NULL,
    x_label = "Monocle3 Pseudotime",
    y_label = "Metagene Trend",
    cell_alpha = vis_params_metagene$cell_alpha,
    cell_size = vis_params_metagene$cell_size,
    cell_stroke = vis_params_metagene$cell_stroke,
    trend_width = vis_params_metagene$trend_width
  )

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
    main_title = "Variance Explained Per PC",
    sub_title = NULL,
    x_label = "Principal Components",
    y_label = "Variance Explained (%)",
    bin_width = vis_params_metagene$bar_width,
    bar_alpha = vis_params_metagene$bar_alpha,
    n_bar = vis_params_metagene$n_pcs,
    activate_legend = reactive({
      FALSE
    })
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
    main_title = "Loadings for Metagene",
    sub_title = NULL,
    x_label = "Principal Component",
    y_label = "Variance Explained (%)",
    bin_width = vis_params_polar$bar_width,
    bar_alpha = vis_params_polar$bar_alpha,
    polar_cord = TRUE,
    n_bar = vis_params_polar$n_pcs,
    activate_legend = reactive({
      FALSE
    })
  )

  lt_xy_server(
    id = "latent_plot",
    x = tsne_coords[, 1, drop = FALSE],
    y = tsne_coords[, 2, drop = FALSE],
    pTime = pTime,
    main_title = "Latent Dimensions",
    catgeory = cell_type,
    sub_title = NULL,
    x_label = "tSNE-1",
    y_label = "tSNE-2",
    cell_alpha = vis_params_latent$cell_alpha,
    cell_size = vis_params_latent$cell_size,
    cell_stroke = vis_params_latent$cell_stroke,
    color_type = "contnious"
  )

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
    sub_title = NULL,
    main_title = "Collective Expression of Loadings",
    color_by = cell_type,
    y_label = "log1p(Expression)",
    x_label = "Monocle3 Pseudotime",
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
    sub_title = NULL,
    color_by = cell_type,
    main_title = "Expression Pattern Over Pseudotime",
    y_label = "log1p(Expression)",
    x_label = "Monocle3 Pseudotime",
    trend_width = vis_params_contri_single$trend_width,
    cell_alpha = vis_params_contri_single$cell_alpha,
    cell_size = vis_params_contri_single$cell_size,
    cell_stroke = vis_params_contri_single$cell_stroke
  )
}
