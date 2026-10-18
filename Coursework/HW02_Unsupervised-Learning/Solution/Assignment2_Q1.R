# @file    Assignment2_Q1.R
# @brief   Dimensionality reduction comparison (PCA, t-SNE, UMAP) on original and filtered gene expression data with convex hull visualization
# @author  Cheolwon Park
# @date    2025-12-01

# 1. 라이브러리 로드
setRepositories(ind = 1:7)
pkg_list <- c("ggplot2", "gridExtra", "grid", "Rtsne", "umap", "stringr")
for (p in pkg_list) {
  if (!require(p, character.only = TRUE)) install.packages(p)
  library(p, character.only = TRUE)
}

# 2. 작업 경로 설정
WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../../data")
if(dir.exists(WORK_DIR)) setwd(WORK_DIR) else warning("경로를 확인하세요.")

# -------------------------------------------------------
# Helper Function: 범례 추출
# -------------------------------------------------------
get_legend <- function(myggplot){
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  if(length(leg) > 0) return(tmp$grobs[[leg]]) else return(NULL)
}

# -------------------------------------------------------
# Helper Function: 개별 플롯 생성 (Convex Hull 적용)
# -------------------------------------------------------
create_plot <- function(df, x_col, y_col, group_col, title_txt, x_lab, y_lab) {

  # Convex Hull 좌표 계산
  hull_data <- do.call(rbind, lapply(split(df, df[[group_col]]), function(d) {
    d[chull(d[[x_col]], d[[y_col]]), ]
  }))

  ggplot(df, aes_string(x = x_col, y = y_col, color = group_col, fill = group_col)) +
    geom_polygon(data = hull_data, alpha = 0.2, show.legend = FALSE) +
    geom_point(size = 1.2, alpha = 0.8) +
    labs(title = title_txt, x = x_lab, y = y_lab) +
    theme_bw() +
    theme(legend.position = "bottom", # 추출용 (나중에 숨김)
          legend.title = element_blank(),
          plot.title = element_text(size = 11, face = "bold"))
}

# -------------------------------------------------------
# Main Analysis Function: 데이터셋 하나를 받아 3개 플롯 반환
# -------------------------------------------------------
analyze_dataset <- function(file_name, label_prefix) {

  if(!file.exists(file_name)) return(NULL)

  # 데이터 로드
  raw_df <- read.delim(file_name, header = TRUE, row.names = 1)

  # 스케일링 수행
  mx_scaled <- scale(raw_df)

  # 중복 제거 (t-SNE 오류 방지)
  unique_idx <- !duplicated(mx_scaled)
  mx_scaled <- mx_scaled[unique_idx, ]

  # 라벨 파싱
  y_labels <- stringr::str_remove(rownames(mx_scaled), "[_0-9]+$")

  # 1) PCA
  fit_pca <- prcomp(mx_scaled, center = FALSE, scale. = FALSE)
  pca_var <- round(fit_pca$sdev^2 / sum(fit_pca$sdev^2) * 100, 1)
  df_pca <- data.frame(X = fit_pca$x[,1], Y = fit_pca$x[,2], Group = y_labels)

  p1 <- create_plot(df_pca, "X", "Y", "Group",
                    paste0("PCA (", label_prefix, ")"),
                    paste0("PC1 (", pca_var[1], "%)"),
                    paste0("PC2 (", pca_var[2], "%)"))

  # 2) t-SNE
  set.seed(2025)
  perp_n <- floor((nrow(mx_scaled) - 1) / 3)
  fit_tsne <- Rtsne(mx_scaled, dims = 2, perplexity = perp_n, check_duplicates = FALSE)
  df_tsne <- data.frame(X = fit_tsne$Y[,1], Y = fit_tsne$Y[,2], Group = y_labels)

  p2 <- create_plot(df_tsne, "X", "Y", "Group",
                    paste0("t-SNE (", label_prefix, ")"), "t-SNE 1", "t-SNE 2")

  # 3) UMAP
  set.seed(2025)
  fit_umap <- umap(mx_scaled, n_neighbors = 15)
  df_umap <- data.frame(X = fit_umap$layout[,1], Y = fit_umap$layout[,2], Group = y_labels)

  p3 <- create_plot(df_umap, "X", "Y", "Group",
                    paste0("UMAP (", label_prefix, ")"), "UMAP 1", "UMAP 2")

  return(list(p1, p2, p3))
}

# -------------------------------------------------------
# 실행 및 통합 출력 (6 Plots Layout)
# -------------------------------------------------------

# 파일명 정의
file_orig <- "1.Homework2_OriginalData.tsv"
file_filt <- "2.Homework2_FilteredData.tsv"

# 분석 실행
plots_orig <- analyze_dataset(file_orig, "Original")
plots_filt <- analyze_dataset(file_filt, "Filtered")

if(!is.null(plots_orig) & !is.null(plots_filt)) {

  # 범례 추출 (Original PCA 그래프에서 하나 가져옴)
  shared_leg <- get_legend(plots_orig[[1]])

  # 모든 개별 그래프에서 범례 숨기기
  pl_list <- c(plots_orig, plots_filt)
  pl_list_noleg <- lapply(pl_list, function(p) p + theme(legend.position = "none"))

  # 그리드 배치 (2행 3열)
  # 상단: Original Data (PCA, t-SNE, UMAP)
  # 하단: Filtered Data (PCA, t-SNE, UMAP)
  # 최하단: 공통 범례

  grid.arrange(arrangeGrob(grobs = pl_list_noleg, nrow = 2, ncol = 3),
               shared_leg,
               nrow = 2,
               heights = c(9, 1), # 그래프 영역 9 : 범례 영역 1 비율
               top = textGrob("Dimension Reduction Result",
                              gp = gpar(fontsize = 14, fontface = "bold")))

} else {
  stop("데이터 파일 중 하나를 찾을 수 없습니다.")
}
