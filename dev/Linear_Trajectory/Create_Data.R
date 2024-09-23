## Load Required Packages
suppressPackageStartupMessages({
  library(monocle3)
  library(pbmcapply)
})

## Load cds
cds <- readRDS("dev/Linear_Trajectory/linear_cds.RDS")

## Extract Cell Metadata
cell_metadata <- as.data.frame(colData(cds))

## Add Pseudotime
cell_metadata$pseudotime <- pseudotime(cds)

## Extract
cell_metadata <- cell_metadata[, c("pseudotime", "cell_type")]
cell_metadata$cell_id <- rownames(cell_metadata)

## Extract Coordinates
coordinates <- reducedDim(cds, "UMAP")
coordinates <- as.data.frame(coordinates)
colnames(coordinates) <- c("UMAP1", "UMAP2")
coordinates$cell_id <- rownames(coordinates)
head(coordinates)

## Merge with Cell Metadata
cell_metadata <- merge(cell_metadata, coordinates, by = "cell_id")

## Extract Count tables
counts <- as.matrix(cds@assays@data@listData$counts)
all(colnames(counts) == cell_metadata$cell_id)

## cell_metadata$cell_type
cell_metadata$cell_type <- gsub("HSC", "Hematopoetic Stem Cells", cell_metadata$cell_type)
cell_metadata$cell_type <- gsub("Early Eryth", "Early Erythroid Progenitors", cell_metadata$cell_type)
cell_metadata$cell_type <- gsub("EMP", "Megakarocyte-Erythroid Progenitors", cell_metadata$cell_type)

## Cell IDS
cell_metadata[cell_metadata$cell_type == "Hematopoetic Stem Cells", "cell_type_id"] <- "HSCs"
cell_metadata[cell_metadata$cell_type == "Early Erythroid Progenitors", "cell_type_id"] <- "EEPs"
cell_metadata[cell_metadata$cell_type == "Megakarocyte-Erythroid Progenitors", "cell_type_id"] <- "MEPs"

## Get Ordered Pseudotime
cell_metadata$pseudotime <- as.numeric(cell_metadata$pseudotime)
cell_metadata <- cell_metadata[order(cell_metadata$pseudotime), ]

## Order counts
counts <- counts[, cell_metadata$cell_id, drop = FALSE]
all(colnames(counts) == cell_metadata$cell_id)

## Load GMT
gmt <- readRDS("dev/Linear_Trajectory/gene_pathway_collapsed_df.RDS")

## Perform normalizaton
sce <- SingleCellExperiment(
  assays = list(counts = counts),
)

## Log norm
sce <- scuttle::logNormCounts(sce)

## Extract Norm Counts
norm_counts <- sce@assays@data@listData$logcounts

## For each of them create subset count tables and compute PC1-PC5 and compute variance using lapply
local_result_list_kegg <- pbmcapply::pbmclapply(c(1:nrow(gmt)), function(i,
                                                                         global_counts = t(norm_counts)) {
  # Get size of Pathway
  row_i <- gmt[i, , drop = FALSE]
  pool <- unlist(strsplit(row_i$GeneSymbol, split = ", "))
  path_id <- row_i$PathwayID
  path_name <- row_i$PathwayName
  rm(row_i)
  if (length(pool) >= 5) {
    sub_x <- as.matrix(global_counts[, colnames(global_counts) %in% pool, drop = FALSE])
    if (ncol(sub_x) >= 5) {
      if (all(colSums(sub_x) > 0)) {
        ## Compute PCA
        tryCatch(
          expr = {
            pca_local <- prcomp(sub_x,
              scale = FALSE,
              center = TRUE,
              rank. = 3
            )
            variance_explained <- (pca_local$sdev)^2 / sum((pca_local$sdev)^2) * 100
            n_genes <- ncol(sub_x)
            return(list(
              pcs = as.matrix(pca_local$x),
              path_id = path_id,
              path_name = sub(" - Homo sapiens \\(human\\)", "", path_name),
              n_genes = n_genes,
              loadings = as.matrix(pca_local$rotation),
              sd = as.matrix(pca_local$sdev),
              variance_explained = variance_explained,
              cum_var = cumsum(variance_explained)
            ))
          },
          error = function(e) {
            return(NULL)
          }
        )
      } else {
        return(NULL)
      }
    } else {
      return(NULL)
    }
  } else {
    return(NULL)
  }
}, mc.cores = 8, ignore.interactive = T)

## Remove any null value list
local_result_list_kegg <- local_result_list_kegg[sapply(local_result_list_kegg, function(x) !is.null(x))]
names(local_result_list_kegg) <- lapply(local_result_list_kegg, function(x) x$path_id)

## Pathways Metagenes
metagene_detected_40 <- lapply(local_result_list_kegg, function(x) {
  if (x$variance_explained[1] >= 30) {
    return(x)
  } else {
    return(NULL)
  }
})
## Remove null
metagene_detected_40 <- metagene_detected_40[sapply(metagene_detected_40, function(x) !is.null(x))]
length(metagene_detected_40)

## Extract Cell-Vertex df
g <- principal_graph(cds)$UMAP
vertex_df <- as_data_frame(g, what = "vertices")
edge_df <- as_data_frame(g, what = "edges")
close_cells <- data.frame(
  cell_id = rownames(cds@principal_graph_aux@listData$UMAP$pr_graph_cell_proj_closest_vertex),
  vertex_id = paste("Y", cds@principal_graph_aux@listData$UMAP$pr_graph_cell_proj_closest_vertex, sep = "_")
)

mst <- as.data.frame(t(as.data.frame(cds@principal_graph_aux@listData$UMAP$dp_mst)))
colnames(mst) <- c("pp_x", "pp_y")
mst$vertex_id <- rownames(mst)

# Merge with cell data
cell_metadata <- merge(close_cells, cell_metadata, by = "cell_id")
cell_metadata <- merge(cell_metadata, mst, by = "vertex_id")

edge_xy <- cell_metadata[, c("vertex_id", "pp_x", "pp_y"), drop = FALSE]
cell_metadata <- cell_metadata[, !colnames(cell_metadata) %in% c("vertex_id", "pp_x", "pp_y")]

edge_df <- merge(edge_df, edge_xy, by.x = "from", by.y = "vertex_id")
colnames(edge_df) <- c("from", "to", "weight", "from_x", "fromy_y")
edge_df <- merge(edge_df, edge_xy, by.x = "to", by.y = "vertex_id")
colnames(edge_df) <- c("from", "to", "weight", "from_x", "from_y", "to_x", "to_y")

# De duplicate
edge_df <- edge_df[!duplicated(edge_df), ]
# Create a list of series for each edge
edges_list <- lapply(1:nrow(edges_df), function(i) {
  list(
    data = list(
      list(x = edges_df$from_x[i], y = edges_df$from_y[i]),
      list(x = edges_df$to_x[i], y = edges_df$to_y[i])
    ),
    type = "line",
    color = "white",
    lineWidth = 3,
    marker = list(enabled = FALSE),
    enableMouseTracking = FALSE,
    showInLegend = FALSE
  )
})

# Prepare nodes data for plotting points
nodes_df <- data.frame(
  x = c(edges_df$from_x, edges_df$to_x),
  y = c(edges_df$from_y, edges_df$to_y)
)

# Remove duplicate nodes if necessary
nodes_df <- nodes_df %>%
  distinct()

metagene_s3 <- metagene_detected_40
cell_data_s3 <- cell_metadata
edge_list_s3 <- edges_list
node_df_s3 <- nodes_df
norm_counts_s3 <- norm_counts

## Save All the data
save(metagene_s3, file = "data/metagene_s3.RData")
save(norm_counts_s3, file = "data/norm_counts_s3.RData")
save(cell_data_s3, file = "data/cell_data_s3.RData")
save(edge_list_s3, file = "data/edge_list_s3.RData")
save(node_df_s3, file = "data/node_df_s3.RData")
tools::resaveRdaFiles(paths = "data/")
