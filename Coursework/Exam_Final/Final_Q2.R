# @file    Final_Q2.R
# @brief   Visualization of the optimal clustering result from Q1 as a PC1-PC2 scatter plot colored by cluster
# @author  Cheolwon Park
# @date    2025-12-17

## 전제: Q1을 이미 실행하여 아래 객체들이 메모리에 존재한다고 가정
## - pca_fit, var_ratio
## - best (최적 조합: Rep, nPC, Metric, Method, k, Score)
## - make_dist (거리 생성 함수)
## 필요 패키지: ggplot2, cluster

cat(">> Q2: Visualizing optimized clustering result from Q1...\n")

## 1) 최적 표현(PC space)과 거리행렬 구성
Zbest <- pca_fit$x[, 1:best$nPC, drop = FALSE]
Dbest <- make_dist(Zbest, metric = best$Metric)

## 2) 최적 방법으로 군집 라벨 재생성(재현성 고정)
set.seed(2025)

if (grepl("^PAM", best$Method)) {
  fit <- pam(Dbest, k = best$k, diss = TRUE)
  final_labels <- as.factor(fit$clustering)
} else if (grepl("^HClust", best$Method)) {
  lnk <- sub("^HClust\\((.*)\\)$", "\\1", best$Method)
  hc <- hclust(Dbest, method = lnk)
  final_labels <- as.factor(cutree(hc, k = best$k))
} else {
  ## KMeans
  Zkm <- Zbest
  if (best$Metric == "cosine") {
    rn <- sqrt(rowSums(Zkm^2)); rn[rn == 0] <- 1
    Zkm <- Zkm / rn
  }
  fit <- kmeans(Zkm, centers = best$k, nstart = 60, iter.max = 300)
  final_labels <- as.factor(fit$cluster)
}

## 3) (검증) 전체 평균 실루엣 재계산(콘솔 출력)
sil <- silhouette(as.integer(final_labels), Dbest)
avg_sil <- mean(sil[, 3])

cat("\n[Q2 Check]\n")
cat(sprintf(" - Best setting: %s | nPC=%d | metric=%s | %s | k=%d\n",
            best$Rep, best$nPC, best$Metric, best$Method, best$k))
cat(sprintf(" - Recomputed overall mean silhouette: %.5f\n", avg_sil))

## 4) 단일 Figure 생성: PC1-PC2 산점도 (클러스터 색으로 구분)
pc1_lab <- paste0("PC1 (", round(var_ratio[1] * 100, 1), "%)")
pc2_lab <- paste0("PC2 (", round(var_ratio[2] * 100, 1), "%)")

viz_df <- data.frame(
  PC1 = Zbest[, 1],
  PC2 = Zbest[, 2],
  Cluster = final_labels
)

p_q2 <- ggplot(viz_df, aes(x = PC1, y = PC2, color = Cluster)) +
  geom_point(alpha = 0.7, size = 1.4) +
  theme_bw() +
  labs(
    title = "Q2. Optimized Clustering Visualization (from Q1)",
    subtitle = paste0(best$Rep, " (nPC=", best$nPC, "), metric=", best$Metric,
                      ", method=", best$Method, ", k=", best$k,
                      ", AvgSil=", sprintf("%.5f", avg_sil)),
    x = pc1_lab,
    y = pc2_lab
  ) +
  theme(legend.position = "right")

print(p_q2)

## 5) (Q2-1) Description 출력(콘솔용)
cat("\n(Q2-1) Description of your analysis:\n")
cat("Q1에서 평균 Silhouette score가 최대가 되는 최적 군집 조합을 선택한 뒤, ")
cat("동일한 PCA 표현 공간에서 최적 알고리즘으로 군집 라벨을 재생성하였다. ")
cat("그 다음 PC1–PC2 평면에 모든 표본을 산점도로 시각화하고, 최적 군집 결과를 클러스터별 서로 다른 색으로 구분하여 표시하였다. ")
cat("해당 단일 그림은 최적 군집 간 분리도와 군집 내 응집도를 직관적으로 보여주어 Q1의 군집화 결과를 시각적으로 뒷받침한다.\n")
