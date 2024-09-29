bslib::page_fluid(
  title = "PCAdash",
  theme = shinythemes::shinytheme("darkly"),
  lang = "en",
  fluidRow(column(8, offset = 2, h3("Pathway Activity Inference in Pseudotime"))),
  fluidRow(column(8, offset = 2, h4("Rationale"))),
  fluidRow(column(8, offset = 2, p("Cell fate decisions are pivotal in cellular development, differentiation, and disease progression. Traditional gene-centric trajectory inference tools often overlook the complexity of cellular functions, which are driven not just by individual genes but by coordinated interactions within pathways. Given the interconnected nature of these processes, it is essential to move beyond simple gene lists and assess how entire pathways evolve over Pseudotime. Pathway metagenes introduces an innovative approach to capture these changes by representing pathway activity as Metagenes in Pseudotime. By leveraging both pathway and trajectory data, this approach evaluates how pathway activity fluctuates across Pseudotime, providing a more holistic view of cellular dynamics.",
    style = "text-align: justify;"
  ))),

  fluidRow(column(8, offset = 2, p("Pseudotime is a metric representing cell's progression through some biological process, relative to a reference cell. It serves as a proxy for developmental time.",
                                   style = "text-align: justify;"
  ))),
  fluidRow(column(8, offset = 2, h4("Workflow for Pathway Metagene Inference"))),
  fluidRow(
    column(6, offset = 3, highcharter::highchartOutput("sankey_workflow") %>% shinycssloaders::withSpinner())
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
  fluidRow(shiny::column(4, offset = 4, lt_xy_ui("latent_plot") %>% shinycssloaders::withSpinner())),
  fluidRow(column(8, offset = 2, hr())),
  ## Variance bar plot
  fluidRow(
    column(8,
      offset = 2,
      fluidRow(
        column(6, offset = 0, var_bar_ui("variance_bar") %>% shinycssloaders::withSpinner()),
        column(6,
          offset = 0, h4("Explained Variance"), p("In a typical scree plot, the eigenvalues-representing the variance captured by each PC-are plotted against the PCs. The plot on the left extends the scree plot by showing the proportion of variance captured on the y-axis and the first 10 PCs on the x-axis.", style = "text-align: justify;"),
          p("In the PCA-Metagene workflow, each PC can be considered a metagene. However, for downstream analysis, we retain only the PCs that capture a substantial amount of variance. Select a pathway from the drop-down list below, and the plot will update to show the proportion of captured variance for first 10 PCs, ideally PC1 and PC2 are considered as metagenes.", style = "text-align: justify;"),
          shiny::selectInput(
            inputId = "pathway_select_var_bar",
            label = NULL,
            choices = NULL
          )
        )
      ),
      hr()
    )
  ),
  fluidRow(
    column(8,
      offset = 2,
      fluidRow(
        column(6,
          offset = 0, h4("Metagene in Pseudotime"), p("Once we have identified the principal components (PCs) with the highest explained variance, we map the score matrix to pseudotime. Instead of examining the behavior of pathways from a gene-centric view, a metagene—which is a PC capturing a substantial amount of variance—allows us to study the collective behaviors of genes in a pathway in a summarized manner. The plot on the right shows how the dynamics of a particular pathway change as the cell differentiates from stem cells to erythrocyte progenitor cells. We visualize this trend using a cubic regression spline with six knots.", style = "text-align: justify;"),
          p("You can select a pathway from the drop-down list below, and the plot will update to show the PC1 metagene in pseudotime.", style = "text-align: justify;"),
          shiny::selectInput(
            inputId = "pathway_select_metagene",
            label =  "Choose a Pathway:",
            choices = NULL
          )
        ),
        column(6, offset = 0, ts_xy_ui("metagene") %>% shinycssloaders::withSpinner())
      ),
      hr()
    )
  ),
  fluidRow(
    column(8,
      offset = 2,
      fluidRow(
        column(6, offset = 0, var_bar_ui("polar_bar") %>% shinycssloaders::withSpinner()),
        column(6,
          offset = 0, h4("Loadings"), p("Loadings indicate how each feature affects the principal components. In our case, the features are genes, so each loading corresponds to a gene within a particular pathway. For simplicity, we're showing only the loadings of the first principal component here. The magnitude of each loading tells us how strongly a particular gene is correlated with the principal component.", style = "text-align: justify;"),
          p("Select a pathway from the drop-down list below, and the plot will update to show the loadings of the selected metagene (PC1).", style = "text-align: justify;"),
          shiny::selectInput(
            inputId = "pathway_select_loading",
            label =  "Choose a Pathway:",
            choices = NULL
          )
        )
      ),
      hr()
    )
  ),
  fluidRow(
    column(8,
      offset = 2,
      fluidRow(
        column(6,
          offset = 0, h4("Contributing Genes"), p("Although the metagene effectively summarizes the overall expression of the pathway gene set, it is still important to examine the expression of individual genes over pseudotime. Doing so helps us better understand which genes have a greater influence on the inferred metagene.", style = "text-align: justify;"),
          p("Select a pathway from the drop-down list, and then choose one of the genes within that pathway. The plot will update to show the expression trend of the selected gene over pseudotime. By comparing this trend with the gene's loading values in the principal component, we can assess how much impact that particular gene has on the metagene. This helps us understand which specific genes are contributing most to the patterns observed in the metagene.", style = "text-align: justify;"),
          column(
            6,
            shiny::selectInput(
              inputId = "pathway_select_contri_gene",
              label = "Choose a Pathway:",
              choices = NULL
            )
          ),
          column(
            6,
            shiny::selectInput(
              inputId = "gene_select",
              label = "Choose a gene:",
              choices = NULL
            )
          )
        ),
        column(6, offset = 0, ts_xy_ui("contri_single") %>% shinycssloaders::withSpinner())
      )
    )
  ),
  hr(),
  # Footer
  tags$footer(
    style = "background-color: #222222; color: white; padding: 5px; position: relative; bottom: 0; width: 100%;",
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
