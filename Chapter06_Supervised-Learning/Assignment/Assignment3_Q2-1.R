# @file    Assignment3_Q2-1.R
# @brief   COVID-19 vs Healthy visualization using PCA, t-SNE, and UMAP dimensionality reduction on gene expression data
# @author  Cheolwon Park
# @date    2025-12-05

## 0. 로드
setRepositories(ind = 1:7)

pkg_list <- c("ggplot2", "Rtsne", "umap", "cowplot")
for (p in pkg_list) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
  }
  library(p, character.only = TRUE)
}


## 1. 작업 경로 설정
WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../../data")
if (dir.exists(WORK_DIR)) {
  setwd(WORK_DIR)
} else {
  warning("경로를 확인하세요.")
}


## 2. 데이터 불러오기
data <- read.delim("Data2.tsv",
                   header = TRUE,
                   sep = "\t",
                   check.names = FALSE)


## 3. 라벨 / 피처 분리
data$Disease <- factor(data$Disease)  # "COVID19", "Healthy"

feature_cols <- setdiff(colnames(data), "Disease")
X <- as.matrix(data[, feature_cols])


## 4. 표준화
X_scaled <- scale(X)

## ------------------------------------------------
## (1) PCA 2D
## ------------------------------------------------
pca <- prcomp(X_scaled, center = FALSE, scale. = FALSE)
pca_var <- pca$sdev^2 / sum(pca$sdev^2)

pca_df <- data.frame(
  PC1 = pca$x[, 1],
  PC2 = pca$x[, 2],
  Disease = data$Disease
)

p_pca <- ggplot(pca_df, aes(x = PC1, y = PC2, color = Disease)) +
  geom_point(alpha = 0.7, size = 1.3) +
  labs(
    title = "PCA",
    x = paste0("PC1 (", round(pca_var[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(pca_var[2] * 100, 1), "%)"),
    color = "Disease"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5)
  )

## ------------------------------------------------
## (2) t-SNE 2D
## ------------------------------------------------
set.seed(2025)

tsne_out <- Rtsne(
  X_scaled,
  dims = 2,
  perplexity = 30,
  verbose = TRUE,
  max_iter = 1000,
  check_duplicates = FALSE
)

tsne_df <- data.frame(
  TSNE1 = tsne_out$Y[, 1],
  TSNE2 = tsne_out$Y[, 2],
  Disease = data$Disease
)

p_tsne <- ggplot(tsne_df, aes(x = TSNE1, y = TSNE2, color = Disease)) +
  geom_point(alpha = 0.7, size = 1.3) +
  labs(
    title = "t-SNE",
    x = "t-SNE 1",
    y = "t-SNE 2",
    color = "Disease"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5)
  )

## ------------------------------------------------
## (3) UMAP 2D
## ------------------------------------------------
set.seed(2025)

umap_config <- umap.defaults
umap_out <- umap(X_scaled, config = umap_config)

umap_df <- data.frame(
  UMAP1 = umap_out$layout[, 1],
  UMAP2 = umap_out$layout[, 2],
  Disease = data$Disease
)

p_umap <- ggplot(umap_df, aes(x = UMAP1, y = UMAP2, color = Disease)) +
  geom_point(alpha = 0.7, size = 1.3) +
  labs(
    title = "UMAP",
    x = "UMAP 1",
    y = "UMAP 2",
    color = "Disease"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5)
  )

## ------------------------------------------------
## (4) 세 그래프(+공용 범례로 결합해서 깔끔하게)
## ------------------------------------------------

## 하나의 플롯에서 legend 추출
legend_b <- cowplot::get_legend(
  p_pca + theme(legend.position = "right")
)

## 각 플롯에서는 legend 제거
p_pca_nl  <- p_pca  + theme(legend.position = "none")
p_tsne_nl <- p_tsne + theme(legend.position = "none")
p_umap_nl <- p_umap + theme(legend.position = "none")

## PCA / t-SNE / UMAP
plot_row <- cowplot::plot_grid(
  p_pca_nl,
  p_tsne_nl,
  p_umap_nl,
  nrow = 1,
  labels = c("A", "B", "C"),
  label_size = 12
)

final_plot <- cowplot::plot_grid(
  plot_row,
  legend_b,
  ncol = 2,
  rel_widths = c(3.5, 0.8)
)

print(final_plot)
