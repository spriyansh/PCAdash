## Set color schemes
dicrete_cell_color <- c("HSC" = "#56B4E9", "EMP" = "#F0E442", "Early Eryth" = "#009E73")

#' @title Custom black theme for ggplot2 objects
#'
#' @description This function applies a custom black theme to ggplot2 plots.
#'
#' @param activate A logical value indicating whether to activate the theme. Defaults to FALSE.
#'
#' @importFrom shinythemes shinytheme
#' @import networkD3
#'
#' @export
black_theme <- function(activate = FALSE) {
  # Activate Selected plot
  if (activate) {
    axis_color <- "#FEF900"
  } else {
    axis_color <- "white"
  }

  theme(
    panel.border = element_blank(),
    panel.background = element_rect(fill = "#222222", color = "#222222"),
    plot.background = element_rect(fill = "#222222", color = "#222222"),
    plot.title = element_text(color = "white", size = rel(1.5)),
    plot.subtitle = element_text(color = "white", size = rel(1.5)),
    panel.grid.major = element_line(linewidth = rel(0.1), linetype = 2, colour = "#f6f6f6"),
    panel.grid.minor = element_blank(),
    axis.text = element_text(colour = "white", size = rel(1.2)),
    axis.line.x = element_line(arrow = arrow(
      angle = 15, length = unit(0.5, "cm"),
      ends = "last", type = "closed"
    ), colour = axis_color),
    axis.line.y = element_line(arrow = arrow(
      angle = 15, length = unit(0.5, "cm"),
      ends = "last", type = "closed"
    ), colour = axis_color),
    axis.ticks = element_line(colour = axis_color),
    axis.title = element_text(color = axis_color, size = rel(1.25)),
    legend.background = element_rect(fill = "#222222", color = "#222222"),
    legend.text = element_text(color = "white"),
    legend.title = element_text(color = "white"),
    legend.key = element_rect(fill = "#222222", color = "#222222"),
    legend.position = "none",
    strip.background = element_rect(fill = "#222222", color = "#222222"),
    strip.text = element_text(color = "white"),
    plot.caption = element_text(color = "white"),
  )
}
