## Make Data available globally
data("pTime", package = "PCAdash")
data("metagene_results", package = "PCAdash")
data("cell_type", package = "PCAdash")
data("tsne_coords", package = "PCAdash")
data("counts", package = "PCAdash")

## Set color schemes
dicrete_cell_color <- c("HSC" = "#56B4E9", "EMP" = "#F0E442", "Early Eryth" = "#009E73")

## Set black_theme
black_theme <- theme_linedraw() + theme(
  panel.border = element_blank(),
  panel.background = element_blank(),
  plot.background = element_rect(color = "#222222", fill = "#222222"),
  plot.title = element_text(color = "white", size = rel(1.5)),
  plot.subtitle = element_text(color = "white", size = rel(1.5)),
  panel.grid.major = element_line(linewidth = rel(0.1), linetype = 2, colour = "#f6f6f6"),
  panel.grid.minor = element_blank(),
  axis.text = element_text(colour = "white", size = rel(1.2)),
  axis.line.x = element_line(arrow = arrow(
    angle = 15, length = unit(0.5, "cm"),
    ends = "last", type = "closed"
  ), colour = "white"),
  axis.line.y = element_line(arrow = arrow(
    angle = 15, length = unit(0.5, "cm"),
    ends = "last", type = "closed"
  ), colour = "white"),
  axis.ticks = element_line(colour = "white"),
  axis.title = element_text(color = "white", size = rel(1.25)),
  legend.position = "none"
)

#
# options(shiny.autoreload = TRUE)
# shiny::runApp(
#     appDir = "/home/priyansh/gitDockers/PCAdash/inst/app/",
#     launch.browser = TRUE, display.mode = "normal"
# )
#
