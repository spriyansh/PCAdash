# sce <- readRDS("dev/rep1_HSC_EMP_EarlyEryth_SCE_Slingshot.RDS")
#
# # Extract Pseudotime Vector
# pTime <- sce@colData$sling_pseudotime
#
# # Order
# pTime <- pTime[order(pTime)]
#
# # Save the raw counts
# save(pTime, file = "data/pTime.RData")
#
# # Extract Counts
# counts <- as.matrix(sce@assays@data@listData$counts)
#
# # Order
# counts <- counts[, names(pTime)]
#
# # Save the raw counts
# save(counts, file = "data/counts.RData")
#
# # Extract Cells
# cell_type <- sce@colData$cell_type
# names(cell_type) <- rownames(sce@colData)
#
# # Oder by pseudotime
# cell_type <- cell_type[names(pTime)]
#
# # Save the raw counts
# save(cell_type, file = "data/cell_type.RData")
#
# # Load the gene expression data
# kegg_data <- read.table("dev/gProfiler_hsapiens_8-9-2024_11-43-02 AM__intersections.csv", header = TRUE, sep = ",")
#
# kegg_data <- kegg_data[, c(2, 3, 6, 10)]
#
# kegg_data <- kegg_data[-1, ]
#
# write.table(kegg_data, file = "dev/kegg_data.txt", sep = "\t", quote = FALSE, row.names = FALSE)
#
# # Save Tsne Coords
# tsne_coords <- as.matrix(reducedDims(sce)[["TSNE"]])
# save(tsne_coords, file = "data/tsne_coords.RData")
#
#
# # Apply
#
# library(stringr)
# pca_res <- lapply(kegg_data$term_name, function(term, counts_matrix = counts, min_size = 5,
#                                                 scale = TRUE, center = TRUE,
#                                                 log1p = TRUE, min_var = 40) {
#   # term <- "Bile secretion"#kegg_data$term_name[1]
#   # min_size = 10
#   # scale = TRUE
#   # center = TRUE
#   # log1p = TRUE
#   # counts_matrix = counts
#
#   if (log1p) {
#     counts_matrix <- log1p(counts_matrix)
#   }
#
#   # Extract the genes
#   genesset <- kegg_data[kegg_data$term_name == term, "intersections"]
#
#   # Split by command and make a numeric vector
#   genesset <- unlist(str_split(genesset, pattern = ","))
#
#   print(term)
#
#   # Extract the counts
#   sub_mat <- counts_matrix[rownames(counts_matrix) %in% genesset, , drop = FALSE]
#
#   if (nrow(sub_mat) < min_size & length(sub_mat) == 0) {
#     return(NULL)
#   } else if (length(sub_mat) > 1) {
#     sub_mat <- as.matrix(t(sub_mat))
#
#     # Compute PCA
#     prcomp_obj <- prcomp(sub_mat, center = center, scale = scale)
#
#     # 1. Extract the Principal Components (PC)
#     PC <- prcomp_obj$x
#
#     # 2. Extract the Loadings
#     loadings <- prcomp_obj$rotation
#
#     # 3. Extract the Variance Per Principal Component (explained variance)
#     variance_per_pc <- (prcomp_obj$sdev)^2
#
#     # 5. Capture the proportion of variance explained by each PC
#     cum_variance <- (variance_per_pc / sum(variance_per_pc)) * 100
#
#     term_size <- kegg_data[kegg_data$term_name == term, "term_size"]
#
#     if (cum_variance[1] > min_var) {
#       # Return
#       return(list(
#         term = term, PC = PC[, 1, drop = FALSE], loadings = loadings[, 1, drop = FALSE], variance_per_pc = variance_per_pc,
#         term_size = term_size
#       ))
#     } else {
#       return(NULL)
#     }
#   } else {
#     return(NULL)
#   }
# })
#
# # Assuming your list is named pca_final_list
# metagene_results <- Filter(Negate(is.null), pca_res)
# names(metagene_results) <- sapply(metagene_results, function(x) x$term)
# length(metagene_results)
#
# metagene_results <- lapply(metagene_results, function(x) {
#   if (nrow(x[["loadings"]]) < 4) {
#     return(NULL)
#   } else {
#     return(x)
#   }
# })
# metagene_results <- Filter(Negate(is.null), metagene_results)
# length(metagene_results)
#
# table(unlist(lapply(metagene_results, function(x) {
#   nrow(x[["loadings"]])
# })))
#
# # Save Object as RDS
# save(metagene_results,
#   file = "data/metagene_results.RData"
# )
# tools::resaveRdaFiles("data/")
