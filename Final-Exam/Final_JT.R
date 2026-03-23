# @file    Final_JT.R
# @brief   Data exploration and sanity check for exam datasets (dimensions, columns, NA counts, column differences)
# @author  Cheolwon Park
# @date    2025-12-17

setRepositories(ind = 1:7)
if (!require("data.table")) install.packages("data.table")
library(data.table)

WORK_DIR <- "../data"
if (dir.exists(WORK_DIR)) setwd(WORK_DIR)
getwd()

cat("===== Load Data1.tsv =====\n")
d1 <- fread("Data1.tsv", sep = "\t", header = TRUE, data.table = FALSE, check.names = FALSE)
cat("dim(Data1) = "); print(dim(d1))
cat("First 30 colnames(Data1):\n"); print(head(colnames(d1), 30))
cat("Last 30 colnames(Data1):\n"); print(tail(colnames(d1), 30))
cat("NA count in Data1 (top 20 columns):\n"); print(head(sort(colSums(is.na(d1)), decreasing = TRUE), 20))

cat("\n===== Load Data2_test.tsv =====\n")
d2 <- fread("Data2_test.tsv", sep = "\t", header = TRUE, data.table = FALSE, check.names = FALSE)
cat("dim(Data2_test) = "); print(dim(d2))
cat("First 30 colnames(Data2_test):\n"); print(head(colnames(d2), 30))
cat("Last 30 colnames(Data2_test):\n"); print(tail(colnames(d2), 30))
cat("NA count in Data2_test (top 20 columns):\n"); print(head(sort(colSums(is.na(d2)), decreasing = TRUE), 20))

cat("\n===== Column Difference Check =====\n")
only_in_d1 <- setdiff(colnames(d1), colnames(d2))
only_in_d2 <- setdiff(colnames(d2), colnames(d1))
cat("Columns only in Data1 (should include race, FEV1_utah):\n"); print(only_in_d1)
cat("Columns only in Data2_test:\n"); print(only_in_d2)

cat("\n===== Candidate ID / Label Check (optional) =====\n")
cat("First column name (Data1): ", colnames(d1)[1], "\n")
cat("First column name (Data2_test): ", colnames(d2)[1], "\n")
cat("Head of first column values (Data1):\n"); print(head(d1[[1]]))
cat("Head of first column values (Data2_test):\n"); print(head(d2[[1]]))
