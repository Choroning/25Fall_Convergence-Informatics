# @file    Assignment2_Q3.R
# @brief   Hierarchical clustering with Ward's method on filtered gene expression data and horizontal dendrogram visualization
# @author  Cheolwon Park
# @date    2025-12-01

# 1. 라이브러리 로드
setRepositories(ind = 1:7)
# 시각화를 위한 factoextra와 스타일 조정을 위한 ggplot2 로드
pkg_list <- c("factoextra", "ggplot2")
for (p in pkg_list) {
  if (!require(p, character.only = TRUE)) install.packages(p)
  library(p, character.only = TRUE)
}

# 2. 작업 경로 설정
WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../../data")
if(dir.exists(WORK_DIR)) setwd(WORK_DIR) else warning("경로를 확인하세요.")

# 3. 데이터 로드 및 전처리 (단독 실행 보장)
target_file <- "2.Homework2_FilteredData.tsv"

if(file.exists(target_file)) {
  # 데이터 로드
  raw_dataset <- read.delim(target_file, header = TRUE, row.names = 1)

  # [Standardization] 데이터 표준화 (Z-score)
  z_score_matrix <- scale(raw_dataset)

  # 4. 계층적 군집 분석 (Hierarchical Clustering)
  # Distance: Euclidean, Linkage: Ward.D2
  dist_metric <- dist(z_score_matrix, method = "euclidean")
  hierarchical_model <- hclust(dist_metric, method = "ward.D2")

  # 5. 시각화 (Horizontal Dendrogram)
  # - horiz = TRUE: 가로로 눕혀서 이름이 잘리지 않게 함
  # - margin(r=150): 오른쪽 여백을 넉넉히 주어 긴 이름도 표시

  viz_tree <- fviz_dend(hierarchical_model, k = 4,
                        horiz = TRUE,              # [핵심] 가로형 배치
                        cex = 0.7,                 # 폰트 크기
                        k_colors = "jco",          # JCO 출판용 색상
                        color_labels_by_k = TRUE,  # 그룹별 라벨 색상
                        rect = TRUE,               # 그룹 박스 표시
                        rect_border = "jco",
                        rect_fill = TRUE,
                        main = "Hierarchical Clustering Dendrogram (Ward's Method)",
                        xlab = "Samples", ylab = "Height (Euclidean Distance)") +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0.5), # 제목: 볼드, 중앙 정렬
      plot.margin = margin(t = 10, r = 10, b = 10, l = 10) # 가로형이므로 기본 여백만 있어도 충분
    )

  print(viz_tree)
  cat(">> Q3. Hierarchical Clustering Analysis Completed (Horizontal View).\n")

} else {
  stop("데이터 파일을 찾을 수 없습니다. 경로를 확인해주세요.")
}
