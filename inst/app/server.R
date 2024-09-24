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

  observeEvent(input$pathway_select, {
    req(input$pathway_select)
    # Load columns
    col_names <- data.table::fread(
      file = "www/data/metagene_matrix_s3.txt",
      sep = "\t", header = FALSE, data.table = FALSE,
      stringsAsFactors = TRUE,
      nrows = 1
    )
    idx <- which(col_names == input$pathway_select)

    # Load metagene data
    metagene_vals <- data.table::fread(
      file = "www/data/metagene_matrix_s3.txt",
      sep = "\t", header = TRUE, data.table = FALSE,
      stringsAsFactors = FALSE,
      select = idx
    )
    pseudotime <- data.table::fread(
      file = "www/data/cell_data_s3.txt",
      sep = "\t", header = TRUE, data.table = FALSE,
      stringsAsFactors = TRUE,
      select = 2
    )

    # Compute Smoother
    metagene_ts <- data.frame(pseudotime = pseudotime[, 1], metagene = metagene_vals[, 1])
    smoothed_data <- with(metagene_ts, smooth.spline(pseudotime, metagene, spar = 2))
    smoothed_df <- data.frame(pseudotime = smoothed_data$x, metagene = smoothed_data$y)

    smoothed_data <- smoothed_df %>%
      dplyr::arrange(pseudotime) %>%
      dplyr::mutate(x = pseudotime, y = metagene) %>%
      dplyr::select(x, y)

    # For original data
    original_data <- metagene_ts %>%
      dplyr::arrange(pseudotime) %>%
      dplyr::mutate(x = pseudotime, y = metagene) %>%
      dplyr::select(x, y)


    ts_xy_server(
      id = "metagene",
      smoothed_data = reactive(smoothed_data),
      original_data = reactive(original_data),
      main_title = "Metagene Over Pseudotime",
      sub_title = NULL,
      x_label = "Monocle3 Pseudotime",
      y_label = "Metagene Trend"
    )
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

  observeEvent(input$gene_select, {
    req(input$gene_select)

    # Load columns
    col_names <- data.table::fread(
      file = "www/data/norm_counts_s3.txt",
      sep = "\t", header = FALSE, data.table = FALSE,
      stringsAsFactors = TRUE,
      nrows = 1
    )
    idx <- which(col_names == input$gene_select)

    # Load metagene data
    count_vals <- data.table::fread(
      file = "www/data/norm_counts_s3.txt",
      sep = "\t", header = TRUE, data.table = FALSE,
      stringsAsFactors = FALSE,
      select = idx
    )
    pseudotime <- data.table::fread(
      file = "www/data/cell_data_s3.txt",
      sep = "\t", header = TRUE, data.table = FALSE,
      stringsAsFactors = TRUE,
      select = 2
    )

    # Compute Smoother
    count_ts <- data.frame(pseudotime = pseudotime[, 1], count = count_vals[, 1])
    smoothed_data <- with(count_ts, smooth.spline(pseudotime, count, spar = 2))
    smoothed_df <- data.frame(pseudotime = smoothed_data$x, count = smoothed_data$y)

    smoothed_data <- smoothed_df %>%
      dplyr::arrange(pseudotime) %>%
      dplyr::mutate(x = pseudotime, y = count) %>%
      dplyr::select(x, y)

    # For original data
    original_data <- count_ts %>%
      dplyr::arrange(pseudotime) %>%
      dplyr::mutate(x = pseudotime, y = count) %>%
      dplyr::select(x, y)

    ts_xy_server(
      id = "contri_single",
      smoothed_data = reactive(smoothed_data),
      original_data = reactive(original_data),
      main_title = "Metagene Over Pseudotime",
      sub_title = NULL,
      x_label = "Monocle3 Pseudotime",
      y_label = "Metagene Trend"
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

  output$sankey_workflow <- highcharter::renderHighchart({
    # Load necessary library
    library(highcharter)

    # Create analysis_flow_nodes data frame
    analysis_flow_nodes <- data.frame(
      name = c(
        "Raw Counts", "Normalized Counts", "KEGG DB", "Subset by GeneSet", "Subset-Pathway-1",
        "Subset-Pathway-2", "Subset-Pathway-3", "Subset-Pathway-4", "Subset-Pathway-...",
        "Subset-Pathway-n", "PC-Max-Var", "PC-Max-Var", "PC-Max-Var", "PC-Max-Var", "PC-Max-Var",
        "PC-Max-Var", "Monocle3", "Inferred Pseudotime", "Meagene-1", "Meagene-2", "Meagene-3",
        "Meagene-4", "Meagene-...", "Meagene-N"
      ),
      node = 0:23,
      grp = rep("same_node", 24),
      stringsAsFactors = FALSE
    )

    # Create analysis_flow_Links data frame
    analysis_flow_Links <- data.frame(
      source = c(0, 1, 2, 3, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9, 0, 16, 17, 17, 17, 17, 17, 17, 10, 11, 12, 13, 14, 15),
      target = c(1, 3, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 18, 19, 20, 21, 22, 23),
      value = c(20, 20, 20, 10, 10, 10, 10, 10, 10, 5, 5, 5, 5, 5, 5, 20, 20, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
      grp = rep("same_link", 29),
      stringsAsFactors = FALSE
    )

    # Map node IDs to node names
    node_names <- analysis_flow_nodes$name
    names(node_names) <- as.character(analysis_flow_nodes$node)

    # Prepare data for Sankey diagram
    sankey_links <- data.frame(
      from = node_names[as.character(analysis_flow_Links$source)],
      to = node_names[as.character(analysis_flow_Links$target)],
      weight = analysis_flow_Links$value,
      stringsAsFactors = FALSE
    )

    # Convert data frame to list for highcharter
    sankey_data <- list_parse(sankey_links)

    # Create the Sankey diagram
    highchart() %>%
      hc_chart(type = "sankey") %>%
      hc_add_series(
        data = sankey_data,
        dataLabels = list(
          enabled = TRUE
        )
      ) %>%
      hc_title(text = "Analysis Flow Sankey Diagram")
  })
}
