# Module UI
vis_params_ui <- function(id) {
  ns <- NS(id) # Namespace function
  tagList(
    # Master ID selector
    selectInput(ns("master_id"), "Select Module", choices = c("Module 1", "Module 2")),

    # UI Outputs for dynamically generated sliders
    uiOutput(ns("module_ui"))
  )
}
