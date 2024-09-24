shiny::navbarPage(
  title = "PCAdash",
  theme = shinythemes::shinytheme("darkly"),
  lang = "en",
  tabPanel(
    "Metagenes",
    fluidRow(column(8, offset = 2, h3("Inference Pathway Activity in Pseudotime"))),
    fluidRow(column(8, offset = 2, h4("Rationale"))),
    fluidRow(column(8, offset = 2, p("Cell fate decisions are pivotal in cellular development, differentiation, and disease progression. Traditional gene-centric trajectory inference tools often overlook the complexity of cellular functions, which are driven not just by individual genes but by coordinated interactions within pathways. Given the interconnected nature of these processes, it is essential to move beyond simple gene lists and assess how entire pathways evolve over Pseudotime. Pathway metagenes introduces an innovative approach to capture these changes by representing pathway activity as Metagenes in Pseudotime. By leveraging both pathway and trajectory data, our approach evaluates how pathway activity fluctuates across Pseudotime, providing a more holistic view of cellular dynamics.",
      style = "text-align: justify;"
    ))),
    fluidRow(column(8, offset = 2, h4("Workflow for Pathway Metagene Inference"))),
    fluidRow(
      column(6, offset = 3, networkD3::sankeyNetworkOutput("sankey_workflow"))
    ),
    fluidRow(
      column(8, offset = 2, p("The workflow above illustrates the steps involved in inferring pathway activity over Pseudotime:"))
    ),
    fluidRow(column(8, offset = 2, HTML("<ul>
  <li>Starting from raw counts, the data is normalized and subsetted based on a gene set of interest.</li>
  <li>The subsetted data is then used to infer pseudotime using Monocle3.</li>
  <li>The gene sets are taken from publicly available knowledge bases, such as KEGG.</li>
  <li>For each gene set, the processed count table is subsetted accordingly.</li>
  <li>An independent principal component analysis (PCA) is performed for each gene set using a correlation-based approach.</li>
  <li>Principal components with the highest captured variance, exceeding a specified threshold, are referred to as 'metagenes.'</li>
  <li>The inferred pseudotime from Monocle3, after trajectory inference, is transferred to the metagenes.</li>
  <li>This allows for the visualization of metagene behavior in pseudotime, helping to infer how pathway behavior is coordinated during changes in cell states.</li>
</ul>"))),
    hr(), # Footer
    tags$footer(
      style = "background-color: #222222; color: white; padding: 10px; position: relative; bottom: 0; width: 100%;",
      shiny::div(
        style = "display: flex; justify-content: space-between;",
        shiny::div(
          style = "text-align: left;",
          shiny::HTML("&copy; 2024 Priyansh Srivastava")
        ),
        shiny::div(
          style = "text-align: right;",
          shiny::HTML("Contact: <a href='https://www.priyansh-efolio.in/'>priyansh-efolio.in</a>")
        )
      )
    )
  ),
  tabPanel(
    "Visualise",
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::h2("Control Panel"),
        br(),
        shiny::selectInput(
          inputId = "pathway_select",
          label = "Choose a Pathway:",
          choices = NULL
        ),
        shiny::selectInput(
          inputId = "gene_select",
          label = "Choose a gene:",
          choices = NULL
        ),
        hr(),
        shiny::selectInput(
          inputId = "plot_select",
          label = "Choose a Plot",
          choices = list(
            "Metagene Over Pseudotime" = "metagene",
            "Variance per PC" = "variance_bar",
            "t-SNE Plot" = "latent_plot",
            "Contributing Genes" = "contri_features",
            "Single Contributing Genes" = "contri_features_single",
            "Loadings" = "variance_polar"
          )
        ),
        hr(),
        shiny::h4("Adjust Visuals "),
        uiOutput("dynamic_vis_params_ui"),
        width = 3
      ),
      shiny::mainPanel(
        width = 9,
        shiny::fluidRow(
          shiny::column(4, var_bar_ui("variance_bar") %>% shinycssloaders::withSpinner()),
          shiny::column(4, ts_xy_ui("metagene")),
          shiny::column(4, lt_xy_ui("latent_plot") %>% shinycssloaders::withSpinner()),
        ),
        hr(),
        shiny::fluidRow(
          shiny::column(4, multi_ts_xy_ui("contri_genes")),
          shiny::column(4, ts_xy_ui("contri_single")),
          shiny::column(4, var_bar_ui("polar_bar") %>% shinycssloaders::withSpinner())
        )
      )
    ),
    hr(),
    # Footer
    tags$footer(
      style = "background-color: #222222; color: white; padding: 10px; position: relative; bottom: 0; width: 100%;",
      shiny::div(
        style = "display: flex; justify-content: space-between;",
        shiny::div(
          style = "text-align: left;",
          shiny::HTML("&copy; 2024 Priyansh Srivastava")
        ),
        shiny::div(
          style = "text-align: right;",
          shiny::HTML("Contact: <a href='https://www.priyansh-efolio.in/'>priyansh-efolio.in</a>")
        )
      )
    )
  )
)
