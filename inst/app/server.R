function(input, output, session) {
  # Plan for async
  future::plan(future::multisession)

  # Initialize reactiveVal for metagene_id
  metagene_id <- reactiveVal(NULL)
  gene_list <- reactiveVal(NULL)
  activate_legend <- reactiveVal(FALSE)

  # Create promises for data loading
  cell_data_promise <- promises::future_promise({
    data.table::fread(
      file = "www/data/cell_data_s3.txt",
      sep = "\t", header = TRUE, data.table = FALSE,
      stringsAsFactors = TRUE
    )
  })

  node_data_promise <- promises::future_promise({
    data.table::fread(
      file = "www/data/node_df_s3.txt",
      sep = "\t", header = TRUE, data.table = FALSE,
      stringsAsFactors = TRUE
    )
  })

  edge_list_data_promise <- promises::future_promise({
    readRDS("www/data/edge_list_s3.RDS")
  })

  # Async load metagenes
  metagene_gene_level_promise <- promises::future_promise({
    data.table::fread(
      file = "www/data/metagene_df_gene_level_s3.txt",
      sep = "\t", header = TRUE,
      data.table = TRUE,
      stringsAsFactors = FALSE
    )
  })

  # Async PC info
  pc_info_promise <- promises::future_promise({
    data.table::fread(
      file = "www/data/pc_info_s3.txt",
      sep = "\t", header = TRUE,
      data.table = TRUE,
      select = c(1:4),
      stringsAsFactors = FALSE
    )
  })

  # Define Reactive
  metagene_id_list <- reactiveVal(NULL)
  gene_level_info <- reactiveVal(NULL)
  pc_info <- reactiveVal(NULL)
  # Use promise_all to wait for both data loading promises
  promises::promise_all(metagene_gene_level = metagene_gene_level_promise, pc_info = pc_info_promise) %...>% (function(data_list) {
    metagene_id_list_tmp <- unique(unlist(data_list$metagene_gene_level$path_id))
    gene_level_info(data_list$metagene_gene_level)
    names(metagene_id_list_tmp) <- unique(unlist(data_list$metagene_gene_level$name))
    metagene_id_list(metagene_id_list_tmp)
    pc_info(data_list$pc_info)
  }) %...!% (function(error) {
    showNotification(paste("Error Metagene data:", error$message), type = "error")
  })


  # Reactive value to store the cell data
  cell_data <- reactiveVal(NULL)
  node_data <- reactiveVal(NULL)
  edge_list_data <- reactiveVal(NULL)
  # Use promise_all to wait for both data loading promises
  promises::promise_all(cell = cell_data_promise, node = node_data_promise, edge_list = edge_list_data_promise) %...>% (function(data_list) {
    cell_data(data_list$cell)
    node_data(data_list$node)
    edge_list_data(data_list$edge_list)
  }) %...!% (function(error) {
    showNotification(paste("Error loading data:", error$message), type = "error")
  })

  # Load UMAP coordinates
  observeEvent(list(cell_data(), node_data(), edge_list_data()), {
    req(cell_data(), node_data(), edge_list_data())
    lt_xy_server(
      id = "latent_plot",
      df = cell_data,
      x_col = "UMAP1",
      y_col = "UMAP2",
      grp_col = "cell_type",
      node_df = node_data,
      node_y_col = "y",
      node_x_col = "x",
      edge_list = edge_list_data
    )
  })

  # Update the selectInput with the pathway lists
  observeEvent(metagene_id_list(), {
    req(metagene_id_list())
    updateSelectInput(
      session,
      inputId = "pathway_select",
      choices = metagene_id_list(),
      selected = metagene_id_list()[1]
    )
  })

  # Update Selected gene list
  observeEvent(list(input$pathway_select, gene_level_info()), {
    req(input$pathway_select, gene_level_info())
    tmp <- unique(unlist(gene_level_info()[gene_level_info()$path_id == input$pathway_select, "gene", drop = TRUE]))
    updateSelectInput(
      session,
      inputId = "gene_select",
      choices = tmp,
      selected = tmp[1]
    )
    gene_list(tmp)

    loading_info <- gene_level_info()[gene_level_info()$path_id == input$pathway_select, c("gene", "loading"), drop = FALSE]

    # print(loading_info)
    var_bar_server(
      id = "polar_bar",
      df = reactive(loading_info),
      x_col = "gene",
      sd_col = "sd",
      y_col = "loading",
      main_title = "Loading to Metagenes",
      x_label = "Gene Ids",
      y_label = "Loadings",
      sub_title = NULL,
      type = "bar"
    )
  })


  observeEvent(input$gene_select, {
    req(input$gene_select)
    print(input$gene_select)
  })

  observeEvent(list(input$pathway_select, pc_info()), {
    req(input$pathway_select, pc_info())

    # Get subset
    filtered_pc_info <- pc_info()[pc_info()$path_id == input$pathway_select, c("pc", "variance_explained", "sd"), drop = FALSE]

    var_bar_server(
      id = "variance_bar",
      df = reactive(filtered_pc_info),
      y_col = "variance_explained",
      sd_col = "sd",
      x_col = "pc",
      main_title = "Variance Explained Per PC",
      x_label = "Principal Components",
      y_label = "Variance Explained (%)",
      sub_title = NULL
    )
  })

  pTime <- seq(1, 10, 1)
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

  # var_bar_server(
  #   id = "variance_bar",
  #   var_per_pc = reactive({
  #     req(metagene_id())
  #     metagene_results[[metagene_id()]][["variance_per_pc"]]
  #   }),
  #   sd = reactive({
  #     req(metagene_id())
  #     sqrt(metagene_results[[metagene_id()]][["variance_per_pc"]])
  #   }),
  #   main_title = "Variance Explained Per PC",
  #   sub_title = NULL,
  #   x_label = "Principal Components",
  #   y_label = "Variance Explained (%)",
  #   bin_width = vis_params_metagene$bar_width,
  #   bar_alpha = vis_params_metagene$bar_alpha,
  #   n_bar = vis_params_metagene$n_pcs,
  #   activate_legend = reactive({
  #     FALSE
  #   })
  # )

  # var_bar_server(
  #   id = "polar_bar",
  #   var_per_pc = reactive({
  #     req(metagene_id())
  #     loading_vector <- metagene_results[[metagene_id()]][["loadings"]]
  #     loading_vector <- loading_vector[, 1, drop = TRUE]
  #     names(loading_vector) <- rownames(metagene_results[[metagene_id()]][["loadings"]])
  #     return(loading_vector)
  #   }),
  #   sd = reactive({
  #     req(metagene_id())
  #     sqrt(metagene_results[[metagene_id()]][["variance_per_pc"]])
  #   }),
  #   main_title = "Loadings for Metagene",
  #   sub_title = NULL,
  #   x_label = "Principal Component",
  #   y_label = "Variance Explained (%)",
  #   bin_width = vis_params_polar$bar_width,
  #   bar_alpha = vis_params_polar$bar_alpha,
  #   polar_cord = TRUE,
  #   n_bar = vis_params_polar$n_pcs,
  #   activate_legend = reactive({
  #     FALSE
  #   })
  # )

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


  output$sankey_workflow <- networkD3::renderSankeyNetwork({
    ## Nodes
    analysis_flow_nodes <- data.frame(
      name = c(
        "Raw Counts",
        "Normalized Counts",
        "KEGG DB",
        "Subset by GeneSet",
        "Subset-Pathway-1", "Subset-Pathway-2", "Subset-Pathway-3", "Subset-Pathway-4", "Subset-Pathway-...", "Subset-Pathway-n",
        "PC-Max-Var", "PC-Max-Var", "PC-Max-Var", "PC-Max-Var", "PC-Max-Var", "PC-Max-Var",
        "Monocle3", "Inferred Pseudotime",
        "Meagene-1", "Meagene-2", "Meagene-3", "Meagene-4", "Meagene-...", "Meagene-N"
      ),
      node = seq(0, 23)
    )
    analysis_flow_nodes$grp <- as.factor(rep("same_node", nrow(analysis_flow_nodes)))

    ## Links
    analysis_flow_Links <- data.frame(
      source = c(0, 1, 2, rep(3, 6), seq(4, 9), 0, 16, rep(17, 6), seq(10, 15)),
      target = c(1, 3, 3, 4, 5, 6, 7, 8, 9, seq(10, 15), 16, 17, seq(18, 23), seq(18, 23)),
      value = c(20, 20, 20, rep(10, 6), rep(5, 6), 20, 20, rep(5, 6), rep(5, 6))
    )
    analysis_flow_Links$grp <- as.factor(rep("same_link", nrow(analysis_flow_Links)))

    color <- "d3.scaleOrdinal(d3.schemeCategory20).domain(['same_node', 'same_link']).range(['#E69F00', '#009E73'])"
    sankey <- networkD3::sankeyNetwork(
      Links = analysis_flow_Links,
      Nodes = analysis_flow_nodes,
      Source = "source",
      Value = "value",
      NodeGroup = "grp",
      LinkGroup = "grp",
      Target = "target",
      NodeID = "name",
      units = "TWh",
      fontSize = 12,
      nodeWidth = 30,
      nodePadding = 60,
      margin = 0,
      colourScale = color
    )

    # Apply custom JavaScript for text color
    htmlwidgets::onRender(sankey, '
      function(el, x) {
        d3.select(el).selectAll(".node text")
          .style("fill", "white");
      }
    ')
  })
}
