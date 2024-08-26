source("/home/priyansh/gitDockers/PCAdash/R/ts_xy_mod.R")
source("/home/priyansh/gitDockers/PCAdash/R/var_bar_mod.R")
source("/home/priyansh/gitDockers/PCAdash/R/dynamic_controls.R")
shiny::navbarPage(
  title = "PCAdash",
  theme = shinythemes::shinytheme("darkly"),
  lang = "en",
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::h2("Control Panel"),
      br(),
      shiny::h3("Select a Pathway"),
      shiny::selectInput(
        inputId = "pathway_select",
        label = "Choose a Pathway:",
        choices = NULL
      ),
      hr(),
      shiny::selectInput(
        inputId = "plot_select",
        label = "Choose a Plot",
        choices = list(
          "Metagene Over Pseudotime" = "metagene",
          "Variance per PC" = "variance_bar"
        )
      ),
      hr(),
      shiny::h4("Adjust Visuals "),
      vis_params_ui("vis_params"),
      width = 3
    ),
    shiny::mainPanel(
      width = 9,
      shiny::fluidRow(
        shiny::column(4, var_bar_ui("variance_bar")),
        shiny::column(4, ts_xy_ui("metagene")) # ,
        # shiny::column(4, lt_xy_ui("latent_plot")),
      ),
      shiny::br(), shiny::br() # sss,
      # shiny::fluidRow(
      #   shiny::column(4, multi_ts_xy_ui("contri_genes")),
      #   shiny::column(4, ts_xy_ui("contri_single")),
      #   shiny::column(4, var_bar_ui("polar_bar"))
      # )
    )
  ),
  br(), br(),
  # First Footersssssss
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
