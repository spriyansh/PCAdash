# styler::style_dir("../shiny/")

nothingComputed <- function() {
  suppressPackageStartupMessages(require(ggplot2))

  df <- data.frame()
  p <- ggplot(df) +
    geom_point() +
    xlim(0, 10) +
    ylim(0, 10) +
    annotate("text", x = 3.9, y = 5.0, size = 30, col = "#f58a53", label = "(") +
    annotate("text", x = 5, y = 5.6, size = 10, col = "#f58a53", label = "o  o") +
    annotate("text", x = 6.1, y = 5.0, size = 30, col = "#f58a53", label = ")") +
    annotate("text", x = 5, y = 5.1, size = 10, col = "#f58a53", label = "|") +
    geom_segment(aes(x = 4.7, xend = 5.3, y = 4.4, yend = 4.4), size = 2, color = "#f58a53") +
    annotate("text", x = 5, y = 3, size = 6, col = "#f58a53", label = "Nothing to plot!") +
    theme(
      panel.border = element_blank(),
      panel.background = element_blank(),
      plot.background = element_rect(color = "#222222", fill = "#222222"),
      plot.title = element_text(color = "white", size = rel(1.5)),
      panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
      panel.grid.minor = element_blank(),
      axis.text = element_text(colour = "white", size = rel(1.2)),
      axis.line.x = element_line(arrow = arrow(), colour = "white"),
      axis.line.y = element_line(colour = "white"),
      axis.ticks = element_line(colour = "white"),
      axis.title = element_text(color = "white", size = rel(1.25)),
      legend.position = "none"
    )
  return(p)
}

parseInShiny <- function(aftermathObject, genePathwaysTable,
                         aftermathObjectSeurat, genePathwaysTableSeurat) {
  # Required Library
  suppressPackageStartupMessages(require(shiny))
  suppressPackageStartupMessages(require(ggplot2))
  suppressPackageStartupMessages(require(ggformula))
  suppressPackageStartupMessages(require(reshape2))
  suppressPackageStartupMessages(require(shinythemes))
  suppressPackageStartupMessages(require(DT))
  suppressPackageStartupMessages(require(tidyverse))
  suppressPackageStartupMessages(library(shinycssloaders))

  spinType <- 6


  # testing for spliceosome
  pathwayList <- aftermathObject[[6]]
  screeList <- aftermathObject[[2]]
  varList <- aftermathObject[[3]]

  pathwayListSeurat <- aftermathObjectSeurat[[6]]
  screeListSeurat <- aftermathObjectSeurat[[2]]
  varListSeurat <- aftermathObjectSeurat[[3]]

  # Choice of pathways
  choice <- list(names(aftermathObject[[6]]))[[1]]
  names(choice) <- choice

  # UI
  ui <- fluidPage(
    theme = shinytheme("darkly"),
    tags$head(
      tags$style(HTML("
      /* this will affect only the pre elements under the class myclass */
      .myclass pre {
        color: white;
        background-color: #303030;
        border-color: #303030;
        width: 5rem;
      }"))
    ),

    # Title
    navbarPage(
      "Pathway Activity",
      tabPanel("Results Visualizer",
        fluid = TRUE,
        sidebarPanel(
          width = 3,
          selectInput(
            inputId = "pathway_select", label = "Choose a Pathway:",
            choices = choice
          ),

          # Geom point Size
          sliderInput(
            inputId = "pointSize",
            label = "Adjust Cell Size",
            min = 0.5,
            max = 3,
            value = 1,
            step = 0.5
          ),

          # Geom Alpha
          sliderInput(
            inputId = "alphaValue",
            label = "Adjust Cell Alpha",
            min = 0.1,
            max = 1,
            value = 0.3,
            step = 0.1
          ),

          # Degree of freedome
          sliderInput(
            inputId = "splineDF",
            label = "Adjust degree of freedom for Spline",
            min = 1,
            max = 10,
            value = 3,
            step = 1
          ),
          hr(),
          selectInput("dynamicDropdown", "Select a gene to compare", choices = "", selected = ""),
          hr(),
          HTML("<p>Captured variance table:</p>"),
          tableOutput("varianceTable"),
          fluidRow(
            column(6, HTML("<p style='padding-top: 5%;padding-bottom: 0%;'>Number of Genes in Pathway: </p>")),
            div(
              class = "myclass",
              column(6, verbatimTextOutput("numGenePathways", placeholder = F))
            )
          ),
          fluidRow(
            column(6, HTML("<p style='padding-top: 5%;padding-bottom: 0%;'>No. of Calculated Metagene(s): </p>")),
            div(
              class = "myclass",
              column(6, verbatimTextOutput("numMetaGenePathways", placeholder = F))
            )
          )
        ),
        mainPanel(
          width = 9,
          tabsetPanel(
            type = "tabs",
            tabPanel(
              "Raw Counts",
              fluidRow(
                column(7, plotOutput("metaInTime") %>% withSpinner(type = spinType, color = "#fdc659")),
                column(5, plotOutput("screePlot") %>% withSpinner(type = spinType, color = "#fdc659"))
              ),
              hr(),
              fluidRow(
                column(7, plotOutput("multiGeneInTime") %>% withSpinner(type = spinType, color = "#fdc659")),
                column(5, plotOutput("geneInTime") %>% withSpinner(type = spinType, color = "#fdc659"))
              )
            ), tabPanel(
              "Normalized Counts",
              fluidRow(
                column(7, plotOutput("normMetaInTime") %>% withSpinner(type = spinType, color = "#fdc659")),
                column(5, plotOutput("normScreePlot") %>% withSpinner(type = spinType, color = "#fdc659"))
              ),
              hr(),
              fluidRow(
                column(7, plotOutput("normMultiGeneInTime") %>% withSpinner(type = spinType, color = "#fdc659")),
                column(5, plotOutput("normGeneInTime") %>% withSpinner(type = spinType, color = "#fdc659"))
              ) # Fuild row end
            ), tabPanel(
              "Comparisons",
              fluidRow(
                column(6, plotOutput("GeneDensityPlot") %>% withSpinner(type = spinType, color = "#fdc659")),
                column(6, plotOutput("MetaGeneDensityPlot") %>% withSpinner(type = spinType, color = "#fdc659"))
              ),
              hr(),
              fluidRow(
                column(6, plotOutput("SeuratGeneDensityPlot") %>% withSpinner(type = spinType, color = "#fdc659")),
                column(6, plotOutput("SeuratMetaGeneDensityPlot") %>% withSpinner(type = spinType, color = "#fdc659"))
              ),
              hr()
            )
          )
        )
      )
    )
  )


  server <- function(input, output, session) {
    # Create a Progress object
    progress <- shiny::Progress$new()

    # Reactive Metagene Pathway Table
    pathwayTableReactive <- reactive({
      pathwayTable <- as.data.frame(pathwayList[[input$pathway]])
      pathwayTable <- pathwayTable[pathwayTable$pseudotime != Inf, ]
    })

    # Reactive Seurat Metagene Pathway Table
    pathwayTableReactiveSeurat <- reactive({
      pathwayTableSeurat <- as.data.frame(pathwayListSeurat[[input$pathway]])
      pathwayTableSeurat <- pathwayTableSeurat[pathwayTableSeurat$pseudotime != Inf, ]
    })

    # Reactive Gene table
    geneTableReactive <- reactive({
      if (input$pathway %in% genePathwaysTable$pathway) {
        geneTable <- as.data.frame(genePathwaysTable[genePathwaysTable$pathway == input$pathway, ])
        geneTable <- as.data.frame(geneTable[geneTable$pseudotime != Inf, ])
        geneTable
      }
    })

    # Reactive Seurat Gene table
    geneTableReactiveSeurat <- reactive({
      if (input$pathway %in% genePathwaysTableSeurat$pathway) {
        geneTableSeurat <- as.data.frame(genePathwaysTableSeurat[genePathwaysTableSeurat$pathway == input$pathway, ])
        geneTableSeurat <- as.data.frame(geneTableSeurat[geneTableSeurat$pseudotime != Inf, ])
        geneTableSeurat
      }
    })

    # Variance table (Reactive link: reactive metagene table)
    output$varianceTable <- renderTable(
      {
        pathwayTable <- pathwayTableReactive()
        maxDim <- ncol(pathwayTable) - 2
        varTable <- round(as.data.frame(varList[[input$pathway]]))
        varTable <- as.data.frame(varTable[c(1:maxDim), -1])
        colnames(varTable) <- c("Var", "Cum. Var")
        varTable
      },
      rownames = T,
      bordered = T
    )

    # Metagene in Pseudotime plot
    output$metaInTime <- renderPlot({
      pathwayTable <- pathwayTableReactive()
      pathwayTable <- melt(pathwayTable, id = c("cell", "pseudotime"))

      ggplot(pathwayTable, aes(
        x = pseudotime, y = value,
        col = pseudotime
      )) +
        ggtitle(paste("Metagene(s) of", input$pathway)) +
        geom_point(size = input$pointSize, alpha = input$alphaValue, shape = 21, fill = "#f6f6f6") +
        xlab("Pseudotime") +
        scale_color_continuous(type = "viridis") +
        ylab("Trends") +
        theme(
          panel.border = element_blank(),
          panel.background = element_blank(),
          plot.background = element_rect(color = "#222222", fill = "#222222"),
          plot.title = element_text(color = "white", size = rel(1.5)),
          panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
          panel.grid.minor = element_blank(),
          axis.text = element_text(colour = "white", size = rel(1.2)),
          axis.line.x = element_line(arrow = arrow(), colour = "white"),
          axis.line.y = element_line(colour = "white"),
          axis.ticks = element_line(colour = "white"),
          axis.title = element_text(color = "white", size = rel(1.25)),
          legend.position = "none"
        ) +
        geom_spline(
          df = input$splineDF, aes(group = variable), size = rel(1.2),
          stat = "spline", color = "#f58a53", alpha = 1
        )
    })

    # Metagene Scree Plot
    output$screePlot <- renderPlot({
      screeList[[input$pathway]] + ggtitle(paste("Scree plot for", input$pathway)) +
        theme(
          panel.background = element_blank(),
          plot.background = element_rect(color = "#222222", fill = "#222222"),
          plot.title = element_text(color = "white", size = rel(1.5)),
          panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
          panel.grid.minor = element_blank(),
          axis.text = element_text(colour = "white", size = rel(1.2)),
          axis.line = element_line(colour = "white"),
          axis.ticks = element_line(colour = "white"),
          axis.title = element_text(color = "white", size = rel(1)),
          legend.position = "none"
        )
    })

    # Multi Genes in Pseudotime plot
    output$multiGeneInTime <- renderPlot({
      geneTable <- geneTableReactive()
      geneTable <- distinct(geneTable[, c("variable", "value", "pseudotime")])

      ggplot(geneTable, aes(
        x = pseudotime, y = value,
        fill = variable
      )) +
        ggtitle(paste("All genes from", input$pathway)) +
        xlab("Pseudotime") +
        ylab("Trends") +
        theme(
          panel.background = element_blank(),
          panel.border = element_blank(),
          plot.background = element_rect(color = "#222222", fill = "#222222"),
          plot.title = element_text(color = "white", size = rel(1.5)),
          panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
          panel.grid.minor = element_blank(),
          axis.text = element_text(colour = "white", size = rel(1.2)),
          axis.line.x = element_line(arrow = arrow(), colour = "white"),
          axis.line.y = element_line(colour = "white"),
          axis.ticks = element_line(colour = "white"),
          axis.title = element_text(color = "white", size = rel(1.25)),
          legend.position = "none"
        ) +
        geom_spline(
          df = input$splineDF, size = rel(.5),
          stat = "spline", color = "#14918a", alpha = 0.5
        )
    })

    # Single Genes in Pseudotime plot
    output$geneInTime <- renderPlot({
      geneTable <- geneTableReactive()
      geneTable <- distinct(geneTable[, c("variable", "value", "pseudotime")])
      geneTable <- geneTable[toupper(geneTable$variable) == toupper(input$dynamicDropdown), ]
      ggplot(geneTable, aes(
        x = pseudotime, y = value,
        col = pseudotime
      )) +
        ggtitle(paste(input$dynamicDropdown, "from", input$pathway)) +
        geom_point(size = input$pointSize, alpha = input$alphaValue, shape = 21, fill = "#f6f6f6") +
        xlab("Pseudotime") +
        scale_color_continuous(type = "viridis") +
        ylab("Trends") +
        theme(
          panel.background = element_blank(),
          panel.border = element_blank(),
          plot.background = element_rect(color = "#222222", fill = "#222222"),
          plot.title = element_text(color = "white", size = rel(1.5)),
          panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
          panel.grid.minor = element_blank(),
          axis.text = element_text(colour = "white", size = rel(1.2)),
          axis.line.x = element_line(arrow = arrow(), colour = "white"),
          axis.line.y = element_line(colour = "white"),
          axis.ticks = element_line(colour = "white"),
          axis.title = element_text(color = "white", size = rel(1)),
          legend.position = "none"
        ) +
        geom_spline(
          df = input$splineDF, size = rel(1.2),
          stat = "spline", color = "#14918a", alpha = 1
        )
    })

    # Single gene selection events observe
    observe({
      updateSelectInput(session,
        inputId = "dynamicDropdown", label = NULL,
        choices = searchResults()
      )
    })

    # Display events
    searchResults <- reactive({
      geneTable <- as.data.frame(genePathwaysTable[genePathwaysTable$pathway == input$pathway, ])
      geneID <- unique(geneTable$variable)
      geneID
    })

    # Number of genes
    output$numGenePathways <- renderText({
      if (length(geneTableReactive()) != 0) {
        geneTable <- geneTableReactive()
        geneTable <- length(unique(geneTable$variable))
        geneTable
      } else {
        cat("0")
      }
    })

    # Number of Metagene
    output$numMetaGenePathways <- renderText({
      if (length(geneTableReactive()) != 0) {
        metaGeneTable <- pathwayTableReactive()
        metaGeneTable <- ncol(metaGeneTable) - 2
        metaGeneTable
      } else {
        cat("0")
      }
    })


    # Metagene Distribution
    output$MetaGeneDensityPlot <- renderPlot({
      pathwayTable <- pathwayTableReactive()
      pathwayTable <- melt(pathwayTable, id = c("cell", "pseudotime"))

      ggplot(pathwayTable, aes(x = log2(value), color = variable)) +
        geom_density() +
        ggtitle(paste("Density plot for Metagene(s) Counts of", input$pathway)) +
        xlab("log2(Metagene Counts)") +
        ylab("Density") +
        theme(
          panel.border = element_blank(),
          panel.background = element_blank(),
          plot.background = element_rect(color = "#222222", fill = "#222222"),
          plot.title = element_text(color = "white", size = rel(1.5)),
          panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
          panel.grid.minor = element_blank(),
          axis.text = element_text(colour = "white", size = rel(1.2)),
          axis.line.x = element_line(arrow = arrow(), colour = "white"),
          axis.line.y = element_line(colour = "white"),
          axis.ticks = element_line(colour = "white"),
          axis.title = element_text(color = "white", size = rel(1.25)),
          legend.position = "none"
        )
    })

    # Multigene density plot
    output$GeneDensityPlot <- renderPlot({
      geneTable <- geneTableReactive()
      geneTable <- distinct(geneTable[, c("variable", "value", "pseudotime")])

      ggplot(geneTable, aes(x = log2(value), color = variable)) +
        geom_density() +
        ggtitle(paste("Density plot for Genes Counts of", input$pathway)) +
        xlab("log2(Raw Counts)") +
        ylab("Density") +
        theme(
          panel.background = element_blank(),
          panel.border = element_blank(),
          plot.background = element_rect(color = "#222222", fill = "#222222"),
          plot.title = element_text(color = "white", size = rel(1.5)),
          panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
          panel.grid.minor = element_blank(),
          axis.text = element_text(colour = "white", size = rel(1.2)),
          axis.line.x = element_line(arrow = arrow(), colour = "white"),
          axis.line.y = element_line(colour = "white"),
          axis.ticks = element_line(colour = "white"),
          axis.title = element_text(color = "white", size = rel(1)),
          legend.position = "none"
        )
    })


    # Seurat Multigene density plot
    output$SeuratGeneDensityPlot <- renderPlot({
      geneTable <- geneTableReactive()
      geneTable <- distinct(geneTable[, c("variable", "normCount", "pseudotime")])

      ggplot(geneTable, aes(x = log2(normCount), color = variable)) +
        geom_density() +
        ggtitle(paste("Density plot for Normalized Genes  Counts of", input$pathway)) +
        xlab("log2(Normalized Counts)") +
        ylab("Density") +
        theme(
          panel.background = element_blank(),
          panel.border = element_blank(),
          plot.background = element_rect(color = "#222222", fill = "#222222"),
          plot.title = element_text(color = "white", size = rel(1.5)),
          panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
          panel.grid.minor = element_blank(),
          axis.text = element_text(colour = "white", size = rel(1.2)),
          axis.line.x = element_line(arrow = arrow(), colour = "white"),
          axis.line.y = element_line(colour = "white"),
          axis.ticks = element_line(colour = "white"),
          axis.title = element_text(color = "white", size = rel(1)),
          legend.position = "none"
        )
    })


    # Seurat Metagene Density Plot
    output$SeuratMetaGeneDensityPlot <- renderPlot({
      if (length(pathwayTableReactiveSeurat()) != 0) {
        pathwayTableSeurat <- pathwayTableReactiveSeurat()
        print(colnames(pathwayTableSeurat))
        print(head(pathwayTableSeurat))
        pathwayTableSeurat <- melt(pathwayTableSeurat, id = c("cell", "pseudotime"))

        ggplot(pathwayTableSeurat, aes(x = log2(value), color = variable)) +
          geom_density() +
          ggtitle(paste("Density plot for Metagene(s) Counts (Norm) of", input$pathway)) +
          xlab("log2(Metagene Counts(Norm))") +
          ylab("Density") +
          theme(
            panel.border = element_blank(),
            panel.background = element_blank(),
            plot.background = element_rect(color = "#222222", fill = "#222222"),
            plot.title = element_text(color = "white", size = rel(1.5)),
            panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
            panel.grid.minor = element_blank(),
            axis.text = element_text(colour = "white", size = rel(1.2)),
            axis.line.x = element_line(arrow = arrow(), colour = "white"),
            axis.line.y = element_line(colour = "white"),
            axis.ticks = element_line(colour = "white"),
            axis.title = element_text(color = "white", size = rel(1.25)),
            legend.position = "none"
          )
      } else {
        nothingComputed()
      }
    })


    # Norm Metagene in Pseudotime plot
    output$normMetaInTime <- renderPlot({
      if (length(pathwayTableReactiveSeurat()) != 0) {
        pathwayTableSeurat <- pathwayTableReactiveSeurat()
        pathwayTableSeurat <- melt(pathwayTableSeurat, id = c("cell", "pseudotime"))

        ggplot(pathwayTableSeurat, aes(
          x = pseudotime, y = value,
          col = pseudotime
        )) +
          ggtitle(paste("Norm Metagene(s) of", input$pathway)) +
          geom_point(size = input$pointSize, alpha = input$alphaValue, shape = 21, fill = "#f6f6f6") +
          xlab("Pseudotime") +
          scale_color_continuous(type = "viridis") +
          ylab("Trends (Normalized)") +
          theme(
            panel.border = element_blank(),
            panel.background = element_blank(),
            plot.background = element_rect(color = "#222222", fill = "#222222"),
            plot.title = element_text(color = "white", size = rel(1.5)),
            panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
            panel.grid.minor = element_blank(),
            axis.text = element_text(colour = "white", size = rel(1.2)),
            axis.line.x = element_line(arrow = arrow(), colour = "white"),
            axis.line.y = element_line(colour = "white"),
            axis.ticks = element_line(colour = "white"),
            axis.title = element_text(color = "white", size = rel(1.25)),
            legend.position = "none"
          ) +
          geom_spline(
            df = input$splineDF, aes(group = variable), size = rel(1.2),
            stat = "spline", color = "#f58a53", alpha = 1
          )
      } else {
        nothingComputed()
      }
    })

    # Norm Metagene Scree Plot
    output$normScreePlot <- renderPlot({
      screeListSeurat[[input$pathway]] + ggtitle(paste("Scree plot for", input$pathway)) +
        theme(
          panel.background = element_blank(),
          plot.background = element_rect(color = "#222222", fill = "#222222"),
          plot.title = element_text(color = "white", size = rel(1.5)),
          panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
          panel.grid.minor = element_blank(),
          axis.text = element_text(colour = "white", size = rel(1.2)),
          axis.line = element_line(colour = "white"),
          axis.ticks = element_line(colour = "white"),
          axis.title = element_text(color = "white", size = rel(1)),
          legend.position = "none"
        )
    })


    # Multi Genes in Pseudotime plot
    output$normMultiGeneInTime <- renderPlot({
      geneTableSeurat <- geneTableReactiveSeurat()
      geneTableSeurat <- distinct(geneTableSeurat[, c("variable", "value", "pseudotime")])

      ggplot(geneTableSeurat, aes(
        x = pseudotime, y = value,
        fill = variable
      )) +
        ggtitle(paste("All genes from", input$pathway)) +
        xlab("Pseudotime") +
        ylab("Trends (Normalized)") +
        theme(
          panel.background = element_blank(),
          panel.border = element_blank(),
          plot.background = element_rect(color = "#222222", fill = "#222222"),
          plot.title = element_text(color = "white", size = rel(1.5)),
          panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
          panel.grid.minor = element_blank(),
          axis.text = element_text(colour = "white", size = rel(1.2)),
          axis.line.x = element_line(arrow = arrow(), colour = "white"),
          axis.line.y = element_line(colour = "white"),
          axis.ticks = element_line(colour = "white"),
          axis.title = element_text(color = "white", size = rel(1.25)),
          legend.position = "none"
        ) +
        geom_spline(
          df = input$splineDF, size = rel(.5),
          stat = "spline", color = "#14918a", alpha = 0.5
        )
    })



    # Single Normalized gene In Time
    output$normGeneInTime <- renderPlot({
      geneTableSeurat <- geneTableReactiveSeurat()
      geneTableSeurat <- distinct(geneTableSeurat[, c("variable", "value", "pseudotime")])
      geneTableSeurat <- geneTableSeurat[toupper(geneTableSeurat$variable) == toupper(input$dynamicDropdown), ]
      ggplot(geneTableSeurat, aes(
        x = pseudotime, y = value,
        col = pseudotime
      )) +
        ggtitle(paste(input$dynamicDropdown, "from", input$pathway)) +
        geom_point(size = input$pointSize, alpha = input$alphaValue, shape = 21, fill = "#f6f6f6") +
        xlab("Pseudotime") +
        scale_color_continuous(type = "viridis") +
        ylab("Trends (Normalized)") +
        theme(
          panel.background = element_blank(),
          panel.border = element_blank(),
          plot.background = element_rect(color = "#222222", fill = "#222222"),
          plot.title = element_text(color = "white", size = rel(1.5)),
          panel.grid.major = element_line(size = rel(0.1), linetype = 2, colour = "#f6f6f6"),
          panel.grid.minor = element_blank(),
          axis.text = element_text(colour = "white", size = rel(1.2)),
          axis.line.x = element_line(arrow = arrow(), colour = "white"),
          axis.line.y = element_line(colour = "white"),
          axis.ticks = element_line(colour = "white"),
          axis.title = element_text(color = "white", size = rel(1)),
          legend.position = "none"
        ) +
        geom_spline(
          df = input$splineDF, size = rel(1.2),
          stat = "spline", color = "#14918a", alpha = 1
        )
    })
  }
  shinyApp(ui, server)
}



combinedTableObject <- readRDS("genePathwaysTable.RDS")
aftermathObject <- readRDS("aftermathObject.RDS")

parseInShiny(
  aftermathObject = aftermathObject[["rawMetagenes"]],
  genePathwaysTable = combinedTableObject[["rawtableObj"]],
  aftermathObjectSeurat = aftermathObject[["normMetagenes"]],
  genePathwaysTableSeurat = combinedTableObject[["normTableObj"]]
)
