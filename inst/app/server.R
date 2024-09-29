function(input, output, session) {
  # Plan for async
  future::plan(future::multisession)

  # Workflow Sankey Promise
  worflow_sankey_data_promise <- promises::future_promise({
    analysis_flow_nodes <- data.table::fread(
      file = "www/data/analysis_flow_nodes.txt",
      sep = "\t", header = TRUE, data.table = FALSE,
      stringsAsFactors = TRUE
    )
    analysis_flow_Links <- data.table::fread(
      file = "www/data/analysis_flow_links.txt",
      sep = "\t", header = TRUE, data.table = FALSE,
      stringsAsFactors = TRUE
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
    sankey_data <- highcharter::list_parse(sankey_links)
    return(sankey_data)
  })

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

  # Reactive value to store the cell data
  cell_data <- reactiveVal(NULL)
  node_data <- reactiveVal(NULL)
  edge_list_data <- reactiveVal(NULL)
  sankey_list_data <- reactiveVal(NULL)
  # Use promise_all to wait for both data loading promises
  promises::promise_all(sankey_info = worflow_sankey_data_promise, cell = cell_data_promise, node = node_data_promise, edge_list = edge_list_data_promise) %...>% (function(data_list) {
    cell_data(data_list$cell)
    node_data(data_list$node)
    edge_list_data(data_list$edge_list)
    sankey_list_data(data_list$sankey_info)
  }) %...!% (function(error) {
    showNotification(paste("Error loading data:", error$message), type = "error")
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

  # Load UMAP coordinates
  observeEvent(list(cell_data(), node_data(), edge_list_data()), {
    req(cell_data(), node_data(), edge_list_data())
    lt_xy_server(
      id = "latent_plot",
      df = cell_data,
      x_col = "UMAP1",
      y_col = "UMAP2",
      grp_col = "cell_type_id",
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
      inputId = "pathway_select_var_bar",
      choices = metagene_id_list(),
      selected = metagene_id_list()[1]
    )
    updateSelectInput(
      session,
      inputId = "pathway_select_metagene",
      choices = metagene_id_list(),
      selected = metagene_id_list()[1]
    )
    updateSelectInput(
      session,
      inputId = "pathway_select_loading",
      choices = metagene_id_list(),
      selected = metagene_id_list()[2]
    )
    updateSelectInput(
      session,
      inputId = "pathway_select_contri_gene",
      choices = metagene_id_list(),
      selected = metagene_id_list()[1]
    )
  })

  # Update Selected gene list
  observeEvent(list(input$pathway_select_contri_gene, gene_level_info()), {
    req(input$pathway_select_contri_gene, gene_level_info())

    tmp <- unique(unlist(gene_level_info()[gene_level_info()$path_id == input$pathway_select_contri_gene, "gene", drop = TRUE]))

    updateSelectInput(
      session,
      inputId = "gene_select",
      choices = tmp,
      selected = tmp[8]
    )
  })

  observeEvent(list(input$pathway_select_loading, gene_level_info()), {
    req(input$pathway_select_loading, gene_level_info())

    loading_info <- gene_level_info()[gene_level_info()$path_id == input$pathway_select_loading, c("gene", "loading"), drop = FALSE]

    # print(loading_info)
    var_bar_server(
      id = "polar_bar",
      df = reactive(loading_info),
      x_col = "gene",
      sd_col = "sd",
      y_col = "loading",
      x_label = "Gene Ids",
      y_label = "Loadings",
      type = "bar"
    )
  })

  observeEvent(input$pathway_select_metagene, {
    req(input$pathway_select_metagene)
    # Load columns
    col_names <- data.table::fread(
      file = "www/data/metagene_matrix_s3.txt",
      sep = "\t", header = FALSE, data.table = FALSE,
      stringsAsFactors = TRUE,
      nrows = 1
    )
    idx <- which(col_names == input$pathway_select_metagene)
    # idx <- which(col_names == "hsa00513")

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
    cell_type <- data.table::fread(
      file = "www/data/cell_data_s3.txt",
      sep = "\t", header = TRUE, data.table = FALSE,
      stringsAsFactors = TRUE,
      select = 6
    )


    # Compute Smoother
    metagene_ts <- data.frame(
      pseudotime = pseudotime[, 1], metagene = metagene_vals[, 1],
      cell_type = cell_type[, 1]
    )

    # Create Spline Cubic Regression spline
    model <- mgcv::gam(formula = metagene ~ s(pseudotime, k = 6), data = metagene_ts, method = "REML")
    metagene_ts$smoother <- predict(model, newdata = metagene_ts)
    rm(model)

    # Metagene over Pseudotime
    ts_xy_server(
      id = "metagene",
      df = reactive(metagene_ts),
      smoother_col = "smoother",
      time_col = "pseudotime",
      grp_col = "cell_type",
      point_col = "metagene",
      x_label = "Monocle3 Pseudotime",
      y_label = "Metagene Trend"
    )
  })

  observeEvent(list(input$pathway_select_var_bar, pc_info()), {
    req(input$pathway_select_var_bar, pc_info())

    # Get subset
    filtered_pc_info <- pc_info()[pc_info()$path_id == input$pathway_select_var_bar, c("pc", "variance_explained", "sd"), drop = FALSE]

    var_bar_server(
      id = "variance_bar",
      df = reactive(filtered_pc_info),
      y_col = "variance_explained",
      sd_col = "sd",
      x_col = "pc",
      x_label = "Principal Components",
      y_label = "Variance Explained (%)"
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
    cell_type <- data.table::fread(
      file = "www/data/cell_data_s3.txt",
      sep = "\t", header = TRUE, data.table = FALSE,
      stringsAsFactors = TRUE,
      select = 6
    )

    # Compute Smoother
    count_ts <- data.frame(pseudotime = pseudotime[, 1], count = count_vals[, 1], cell_type = cell_type[, 1])

    # Create Spline Cubic Regression spline
    model <- mgcv::gam(formula = count ~ s(pseudotime, k = 6), data = count_ts, method = "REML")
    count_ts$smoother <- predict(model, newdata = count_ts)
    rm(model)

    ts_xy_server(
      id = "contri_single",
      df = reactive(count_ts),
      smoother_col = "smoother",
      time_col = "pseudotime",
      point_col = "count",
      grp_col = "cell_type",
      x_label = "Monocle3 Pseudotime",
      y_label = "Expression Trend"
    )
  })

  observeEvent(sankey_list_data(), {
    req(sankey_list_data())

    output$sankey_workflow <- highcharter::renderHighchart({
      # Create the Sankey diagram
      highcharter::highchart() %>%
        highcharter::hc_chart(type = "sankey") %>%
        highcharter::hc_add_series(
          data = sankey_list_data(),
          dataLabels = list(
            enabled = TRUE
          )
        )
    })
  })
}
