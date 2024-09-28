# Create analysis_flow_nodes data frame
analysis_flow_nodes <- data.frame(
  name = c(
    "Raw Counts", "Normalized Counts", "KEGG DB", "Subset by GeneSet", "Subset-Pathway-1",
    "Subset-Pathway-2", "Subset-Pathway-3", "Subset-Pathway-4", "Subset-Pathway-...",
    "Subset-Pathway-n", "PC-Max-Var", "PC-Max-Var", "PC-Max-Var", "PC-Max-Var", "PC-Max-Var",
    "PC-Max-Var", "Monocle3", "Inferred Pseudotime", "Meagene-1", "Meagene-2", "Meagene-3",
    "Meagene-4", "Meagene-...", "Meagene-N"
  ),
  node = 0:23,
  grp = rep("same_node", 24),
  stringsAsFactors = FALSE
)



# Create analysis_flow_Links data frame
analysis_flow_Links <- data.frame(
  source = c(0, 1, 2, 3, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9, 0, 16, 17, 17, 17, 17, 17, 17, 10, 11, 12, 13, 14, 15),
  target = c(1, 3, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 18, 19, 20, 21, 22, 23),
  value = c(20, 20, 20, 10, 10, 10, 10, 10, 10, 5, 5, 5, 5, 5, 5, 20, 20, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
  grp = rep("same_link", 29),
  stringsAsFactors = FALSE
)

# Save
write.table(analysis_flow_nodes, file = "inst/app/www/data/analysis_flow_nodes.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(analysis_flow_Links, file = "inst/app/www/data/analysis_flow_links.txt", sep = "\t", quote = FALSE, row.names = FALSE)
rm(analysis_flow_nodes)
rm(analysis_flow_Links)
