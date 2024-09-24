# test_that("PCAdash initialize", {
#   shinytest2::load_app_env(app_dir = system.file(package = "PCAdash", "app"))
#   app <- shinytest2::AppDriver$new(
#     app_dir = system.file(package = "PCAdash", "app"),
#     variant = shinytest2::platform_variant(), name = "test-show-sankey", seed = 123
#   )
#   app$expect_screenshot()
#   # Clean up 'Crashpad' directory if it exists
#   temp_dir <- tempdir()
#   crashpad_dir <- file.path(temp_dir, "Crashpad")
#   if (file.exists(crashpad_dir)) {
#     unlink(crashpad_dir, recursive = TRUE)
#   }
#   app$stop()
# })
