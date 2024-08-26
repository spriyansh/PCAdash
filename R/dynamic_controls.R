# Module UI
vis_params_ui <- function(id) {
  ns <- NS(id) # Namespace function
  uiOutput(ns("vis_control_ui"))
}

# Module Server
vis_params_server <- function(id, plot_type,
                              max_bar_pc) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Reactive expression to generate the UI based on the selected plot_type
    output$vis_control_ui <- renderUI({
      if (plot_type() == "metagene") {
        shiny::tagList(
          shiny::sliderInput(
            inputId = ns("cell_alpha"), label = "Cell Transparency",
            min = 0, max = 1, value = 0.7
          ),
          shiny::sliderInput(
            inputId = ns("cell_size"), label = "Cell Size",
            min = 0, max = 1, value = 0.7
          ),
          shiny::sliderInput(
            inputId = ns("cell_stroke"), label = "Cell Stroke",
            min = 0, max = 1, value = 0.7
          ),
          shiny::sliderInput(
            inputId = ns("trend_width"), label = "Trend Width",
            min = 0, max = 1, value = 0.7
          )
        )
      } else if (plot_type() == "variance_bar") {
        shiny::tagList(
          shiny::sliderInput(
            inputId = ns("n_pcs"), label = "Number of PCs",
            min = round(max_bar_pc() / 8), max = max_bar_pc(), value = round(max_bar_pc() / 4)
          ),
          shiny::sliderInput(
            inputId = ns("bar_alpha"), label = "Bar Transparency",
            min = 0, max = 1, value = 0.7
          ),
          shiny::sliderInput(
            inputId = ns("bar_width"), label = "Bar Width",
            min = 0, max = 1, value = 0.7
          )
        )
      }
    })

    # Initialize reactive values with default values
    rv <- reactiveValues(
      cell_alpha = 0.7,
      cell_size = 0.7,
      cell_stroke = 0.7,
      trend_width = 0.7,
      bar_alpha = 0.7,
      bar_width = 0.7,
      n_pcs = 5
    )

    # Update reactive values based on plot_type
    observe({
      if (plot_type() == "metagene") {
        rv$cell_alpha <- ifelse(!is.null(input$cell_alpha), input$cell_alpha, 0.7)
        rv$cell_size <- ifelse(!is.null(input$cell_size), input$cell_size, 0.7)
        rv$cell_stroke <- ifelse(!is.null(input$cell_stroke), input$cell_stroke, 0.7)
        rv$trend_width <- ifelse(!is.null(input$trend_width), input$trend_width, 0.7)
      } else if (plot_type() == "variance_bar") {
        rv$n_pcs <- ifelse(!is.null(input$n_pcs), input$n_pcs, 5)
        rv$bar_alpha <- ifelse(!is.null(input$bar_alpha), input$bar_alpha, 0.7)
        rv$bar_width <- ifelse(!is.null(input$bar_width), input$bar_width, 0.7)
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
