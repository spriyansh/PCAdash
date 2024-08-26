get_variance <- function(metagene_id, data) {
  ## Debugger
  # metagene_id <- "Pathways of neurodegeneration - multiple diseases"
  # data <- metagene_results

  ## Get the variance explained by each PC
  var_per_pc <- data[[metagene_id]]$variance_per_pc

  ## Get the standard deviation of the variance explained by each PC
  sdev_per_pc <- sqrt(var_per_pc)

  ## Return
  return(list(
    var_per_pc = var_per_pc,
    sdev_per_pc = sdev_per_pc
  ))
}
