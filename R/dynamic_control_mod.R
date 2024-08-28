#' @title Dynamic control module
#'
#' @description
#' A Shiny module that generates a dynamic control panel based on the selected plot type.
#'
#' @param id A unique identifier for the module, used to distinguish this module's
#'
#' @export
vis_params_ui <- function(id) {
  ns <- NS(id) # Namespace function
  uiOutput(ns("vis_control_ui"))
}

#' @title Dynamic Control Server Module
#'
#' @description
#' A Shiny server module that generates reactive values based on the selected plot type.
#'
#' @param id A unique identifier for the module, used to distinguish this module's
#' UI and server components from others within a Shiny application.
#' @param plot_type A reactive expression representing the selected plot type.
#' @param max_bar_pc A reactive expression representing the maximum number of PCs to display in the variance plot.
#'
#' @export
vis_params_server <- function(id, plot_type,
                              max_bar_pc = reactive(5)) {
  moduleServer(id, function(input, output, session) {
    # Define Local Variable Set
    trend_width_value <- 1.5
    trend_width_max <- 3
    trend_width_min <- 1
    trend_width_step <- 0.5

    cell_alpha_value <- 0.7
    cell_alpha_max <- 1
    cell_alpha_min <- 0.1
    cell_alpha_step <- 0.1


    cell_size_value <- 2
    cell_size_max <- 3
    cell_size_min <- 1
    cell_size_step <- 0.5

    cell_stroke_value <- 0.5
    cell_stroke_max <- 2
    cell_stroke_min <- 0.1
    cell_stroke_step <- 0.1

    bar_alpha_value <- 0.7
    bar_alpha_max <- 1
    bar_alpha_min <- 0.1
    bar_alpha_step <- 0.1

    bar_width_value <- 0.5
    bar_width_max <- 1
    bar_width_min <- 0.1
    bar_width_step <- 0.1

    n_pcs_value <- 5


    ns <- session$ns
    # Reactive expression to generate the UI based on the selected plot_type
    output$vis_control_ui <- renderUI({
      if (plot_type() %in% c("metagene", "latent_plot", "contri_features", "contri_features_single")) {
        if (plot_type() %in% c("metagene", "contri_features_single")) {
          shiny::tagList(
            shiny::sliderInput(
              inputId = ns("trend_width"), label = "Trend Width",
              min = trend_width_min, max = trend_width_max, value = trend_width_value, step = trend_width_step
            ),
            shiny::sliderInput(
              inputId = ns("cell_alpha"), label = "Cell Transparency",
              min = cell_alpha_min, max = cell_alpha_max, value = cell_alpha_value, step = cell_alpha_step
            ),
            shiny::sliderInput(
              inputId = ns("cell_size"), label = "Cell Size",
              min = cell_size_min, max = cell_size_max, value = cell_size_value, step = cell_size_step
            ),
            shiny::sliderInput(
              inputId = ns("cell_stroke"), label = "Cell Stroke",
              min = cell_stroke_min, max = cell_stroke_max, value = cell_stroke_value, step = cell_stroke_step
            )
          )
        } else if (plot_type() == "contri_features") {
          shiny::sliderInput(
            inputId = ns("trend_width"), label = "Trend Width",
            min = trend_width_min, max = trend_width_max, value = trend_width_value, step = trend_width_step
          )
        } else if (plot_type() == "latent_plot") {
          shiny::tagList(
            shiny::sliderInput(
              inputId = ns("cell_alpha"), label = "Cell Transparency",
              min = cell_alpha_min, max = cell_alpha_max, value = cell_alpha_value, step = cell_alpha_step
            ),
            shiny::sliderInput(
              inputId = ns("cell_size"), label = "Cell Size",
              min = cell_size_min, max = cell_size_max, value = cell_size_value, step = cell_size_step
            ),
            shiny::sliderInput(
              inputId = ns("cell_stroke"), label = "Cell Stroke",
              min = cell_stroke_min, max = cell_stroke_max, value = cell_stroke_value, step = cell_stroke_step
            )
          )
        }
      } else if (plot_type() %in% c("variance_bar", "variance_polar")) {
        shiny::tagList(
          shiny::sliderInput(
            inputId = ns("n_pcs"), label = "Number of PCs",
            min = round(max_bar_pc() / 8), max = max_bar_pc(), value = round(max_bar_pc() / 4)
          ),
          shiny::sliderInput(
            inputId = ns("bar_alpha"), label = "Bar Transparency",
            min = bar_alpha_min, max = bar_alpha_max, value = bar_alpha_value, step = bar_alpha_step
          ),
          shiny::sliderInput(
            inputId = ns("bar_width"), label = "Bar Width",
            min = bar_width_min, max = bar_width_max, value = bar_width_value, step = bar_width_step
          )
        )
      }
    })

    # Initialize reactive values with default values
    rv <- reactiveValues(
      cell_alpha = cell_alpha_value,
      cell_size = cell_size_value,
      cell_stroke = cell_stroke_value,
      trend_width = trend_width_value,
      bar_alpha = bar_alpha_value,
      bar_width = bar_width_value,
      n_pcs = n_pcs_value
    )

    # Update reactive values based on plot_type
    observe({
      if (plot_type() %in% c("metagene", "latent_plot", "contri_features", "contri_features_single")) {
        rv$cell_alpha <- ifelse(!is.null(input$cell_alpha), input$cell_alpha, cell_alpha_value)
        rv$cell_size <- ifelse(!is.null(input$cell_size), input$cell_size, cell_size_value)
        rv$cell_stroke <- ifelse(!is.null(input$cell_stroke), input$cell_stroke, cell_stroke_value)
        rv$trend_width <- ifelse(!is.null(input$trend_width), input$trend_width, trend_width_value)
      } else if (plot_type() %in% c("variance_bar", "variance_polar")) {
        rv$n_pcs <- ifelse(!is.null(input$n_pcs), input$n_pcs, n_pcs_value)
        rv$bar_alpha <- ifelse(!is.null(input$bar_alpha), input$bar_alpha, bar_alpha_value)
        rv$bar_width <- ifelse(!is.null(input$bar_width), input$bar_width, bar_width_value)
      }
    })

    # Return reactive values
    return(list(
      cell_alpha = reactive(rv$cell_alpha),
      cell_size = reactive(rv$cell_size),
      cell_stroke = reactive(rv$cell_stroke),
      trend_width = reactive(rv$trend_width),
      bar_alpha = reactive(rv$bar_alpha),
      bar_width = reactive(rv$bar_width),
      n_pcs = reactive(rv$n_pcs)
    ))
  })
}
