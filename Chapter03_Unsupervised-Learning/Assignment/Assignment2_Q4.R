# @file    Assignment2_Q4.R
# @brief   Optimal K search for K-means clustering using silhouette score on filtered gene expression data
# @author  Cheolwon Park
# @date    2025-12-01

# 1. 라이브러리 로드
setRepositories(ind = 1:7)
# 시각화(factoextra) 및 군집분석(cluster) 라이브러리
pkg_list <- c("factoextra", "cluster", "ggplot2")
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
  raw_df <- read.delim(target_file, header = TRUE, row.names = 1)

  # [Standardization] 스케일링 수행 (필수 과정)
  # K-means는 거리 기반 알고리즘이므로 변수 간 스케일을 맞춰야 함
  std_data <- scale(raw_df)

  # -------------------------------------------------------
  # 4. 실루엣 스코어 플롯 그리기 (k = 2 ~ 10)
  # -------------------------------------------------------
  # fviz_nbclust 함수: 최적의 군집 수를 찾기 위한 시각화 도구
  # - method = "silhouette": 실루엣 계수 사용
  # - k.max = 10: 2부터 10까지 탐색

  viz_silhouette <- fviz_nbclust(std_data, kmeans, method = "silhouette", k.max = 10) +
    labs(title = "Q4. Silhouette Score for K-means Clustering",
         subtitle = "Optimal number of clusters (k) search range: 2-10",
         x = "Number of clusters k",
         y = "Average Silhouette Width") +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.title = element_text(face = "bold")
    )

  # 5. 결과 출력
  print(viz_silhouette)

  # (선택 사항) 계산된 데이터 확인용 출력
  cat(">> Silhouette Score Plot Generated.\n")
  cat(">> Check the plot to find the 'k' with the highest silhouette width.\n")

} else {
  stop("데이터 파일을 찾을 수 없습니다.")
}
