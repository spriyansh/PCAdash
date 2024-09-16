## Test if all the requested packages are installed
testthat::test_that("All required packages are installed", {
  # Read DESCRIPTION file
  desc <- read.dcf(system.file("DESCRIPTION", package = "PCAdash"))

  # Extract dependencies from Depends, Imports, and Suggests
  fields <- c("Imports", "Suggests")

  # Combine dependencies and split by comma
  deps <- desc[1, fields]
  deps <- unlist(strsplit(desc[1, fields], ",|\n"))
  names(deps) <- NULL

  # Clean up package names, remove R version dependencies
  deps <- trimws(deps)
  deps <- deps[deps != ""]

  # Extract package names
  packages <- vapply(deps, FUN = function(X) strsplit(X, " ")[[1]][1], FUN.VALUE = character(1))
  versions <- vapply(deps, FUN = function(X) {
    strsplit(x = X, "\\(>= ")[[1]][[2]]
  }, FUN.VALUE = character(1))
  versions <- gsub("\\)", "", versions)

  # Define run
  required_packages <- packages
  names(required_packages) <- versions

  ## Remove testthat and shinytest2
  required_packages <- required_packages[!(required_packages %in% c("testthat", "shinytest2"))]

  for (pkg in required_packages) {
    testthat::expect_true(requireNamespace(pkg, quietly = TRUE, versionCheck = TRUE),
      info = paste("Package", pkg, "is not installed.")
    )
  }
})
