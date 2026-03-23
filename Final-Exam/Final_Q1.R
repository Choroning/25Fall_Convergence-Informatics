# @file    Final_Q1.R
# @brief   Optimal clustering via silhouette score maximization using PCA, multi-metric, and multi-algorithm two-stage search
# @author  Cheolwon Park
# @date    2025-12-17

## 1. 기본 환경 설정 및 라이브러리 로드
setRepositories(ind = 1:7)

pkg_list <- c("data.table", "cluster", "ggplot2", "cowplot")
for (p in pkg_list) {
  if (!require(p, character.only = TRUE)) install.packages(p)
  library(p, character.only = TRUE)
}

set.seed(2025)

WORK_DIR <- "../data"
if (dir.exists(WORK_DIR)) setwd(WORK_DIR)
getwd()

## 2. 데이터 로드
cat(">> Loading Data1.tsv...\n")
d1 <- fread("Data1.tsv", sep = "\t", header = TRUE, data.table = FALSE, check.names = FALSE)

## 3. 센서 변수 추출 및 표준화
sensor_cols <- grep("^Feature_", colnames(d1), value = TRUE)
X_raw <- d1[, sensor_cols]
X_scaled <- scale(X_raw)  # Z-score

## 4. PCA (한 번만 수행) + 후보 PC 개수 자동 구성
cat(">> Running PCA...\n")
pca_fit <- prcomp(X_scaled, center = FALSE, scale. = FALSE)
var_ratio <- (pca_fit$sdev^2) / sum(pca_fit$sdev^2)
cum_var <- cumsum(var_ratio)

## "하위 PC는 잡음일 수 있음"을 반영: 낮은 누적분산 컷 + 직접 nPC 후보를 함께 탐색(단, 시간 제한)
pca_cuts <- c(0.70, 0.75, 0.80, 0.85, 0.90, 0.95)
npc_from_cut <- sapply(pca_cuts, function(v) which(cum_var >= v)[1])

npc_manual <- c(3, 5, 7, 9, 12, 15, 20, 23, 30)  # 과도한 탐색 방지용 최소 후보군
npc_list <- sort(unique(c(npc_from_cut, npc_manual)))
npc_list <- npc_list[npc_list <= ncol(pca_fit$x)]

rep_names <- paste0("PC", npc_list)

cat("\n[PCA Candidates]\n")
for (i in seq_along(npc_list)) {
  kpc <- npc_list[i]
  cat(sprintf(" - %s : %d PCs (CumVar=%.4f)\n", rep_names[i], kpc, cum_var[kpc]))
}

pc1_lab <- paste0("PC1 (", round(var_ratio[1] * 100, 1), "%)")
pc2_lab <- paste0("PC2 (", round(var_ratio[2] * 100, 1), "%)")

## 5. 거리(metric) 함수 (euclidean/manhattan/cosine)
make_dist <- function(Z, metric = c("euclidean", "manhattan", "cosine")) {
  metric <- match.arg(metric)
  if (metric %in% c("euclidean", "manhattan")) {
    return(dist(Z, method = metric))
  }
  ## cosine distance = 1 - cosine similarity
  rn <- sqrt(rowSums(Z^2))
  rn[rn == 0] <- 1
  Zn <- Z / rn
  sim <- Zn %*% t(Zn)     # 1500x1500 (메모리 허용 범위)
  dmat <- 1 - sim
  diag(dmat) <- 0
  rm(sim); gc()
  return(as.dist(dmat))
}

## 6. 2-Stage Search (시간 단축 + 점수 극대화 지향)
## Stage 1: (Representation × Metric)에서 PAM만으로 빠르게 스크리닝
stage1_search <- function(npc_list, rep_names,
                          metrics = c("euclidean", "manhattan", "cosine"),
                          k_grid = 2:10) {

  out <- data.frame()
  for (i in seq_along(npc_list)) {
    kpc <- npc_list[i]
    rep <- rep_names[i]
    Z <- pca_fit$x[, 1:kpc, drop = FALSE]

    for (m in metrics) {
      cat(sprintf("\n[Stage 1] %s | metric=%s | building distance...\n", rep, m))
      D <- make_dist(Z, metric = m)

      for (k in k_grid) {
        set.seed(2025)
        pm <- pam(D, k = k, diss = TRUE)
        sil <- silhouette(pm$clustering, D)
        out <- rbind(out, data.frame(Rep = rep, nPC = kpc, Metric = m,
                                     Method = "PAM(diss)", k = k,
                                     Score = mean(sil[, 3])))
      }
      rm(D); gc()
    }
  }
  out[order(-out$Score), ]
}

## Stage 2: Stage1 상위 후보만 정밀 탐색 (PAM + HClust + (조건부) KMeans)
stage2_refine <- function(top_candidates,
                          k_grid = 2:15,
                          km_nstart = 60) {

  out <- data.frame()

  ## 상위 후보만 대상으로 실행
  for (r in seq_len(nrow(top_candidates))) {
    rep <- top_candidates$Rep[r]
    kpc <- top_candidates$nPC[r]
    m   <- top_candidates$Metric[r]

    Z <- pca_fit$x[, 1:kpc, drop = FALSE]
    cat(sprintf("\n[Stage 2] %s | metric=%s | building distance...\n", rep, m))
    D <- make_dist(Z, metric = m)

    ## (A) PAM (거리 기반 일관성 최고)
    for (k in k_grid) {
      set.seed(2025)
      pm <- pam(D, k = k, diss = TRUE)
      sil <- silhouette(pm$clustering, D)
      out <- rbind(out, data.frame(Rep = rep, nPC = kpc, Metric = m,
                                   Method = "PAM(diss)", k = k,
                                   Score = mean(sil[, 3])))
    }

    ## (B) Hierarchical (거리 기반이므로 metric 그대로 반영 가능)
    ## ward.D2는 유클리드에서만, 그 외는 average/complete 중심
    linkages <- if (m == "euclidean") c("ward.D2", "complete", "average") else c("complete", "average")
    for (lnk in linkages) {
      hc <- hclust(D, method = lnk)
      for (k in k_grid) {
        cl <- cutree(hc, k = k)
        sil <- silhouette(cl, D)
        out <- rbind(out, data.frame(Rep = rep, nPC = kpc, Metric = m,
                                     Method = paste0("HClust(", lnk, ")"),
                                     k = k, Score = mean(sil[, 3])))
      }
      rm(hc); gc()
    }

    ## (C) KMeans (원래 목적함수는 SSE이지만, silhouette 최대화 후보로만 제한적으로 포함)
    ## - metric이 euclidean이면 그대로
    ## - metric이 cosine이면 row-normalize 후 kmeans를 수행(방향성 군집 유도)
    if (m %in% c("euclidean", "cosine")) {
      Zkm <- Z
      if (m == "cosine") {
        rn <- sqrt(rowSums(Zkm^2)); rn[rn == 0] <- 1
        Zkm <- Zkm / rn
      }
      for (k in k_grid) {
        set.seed(2025)
        km <- kmeans(Zkm, centers = k, nstart = km_nstart, iter.max = 300)
        sil <- silhouette(km$cluster, D)
        out <- rbind(out, data.frame(Rep = rep, nPC = kpc, Metric = m,
                                     Method = "KMeans", k = k,
                                     Score = mean(sil[, 3])))
      }
    }

    rm(D); gc()
  }

  out[order(-out$Score), ]
}

## ----------------------------
## 실행 파라미터(시간/성능 절충)
## ----------------------------
metrics_use <- c("euclidean", "manhattan", "cosine")

k_stage1 <- 2:10     # 빠른 스크리닝
k_stage2 <- 2:15     # 상위 후보만 정밀 탐색
TOP_N_STAGE2 <- 5    # Stage1 상위 N개만 Stage2로

## 7. Stage 1 실행
cat("\n==============================\n")
cat("Stage 1: Fast screening (PAM only)\n")
cat("==============================\n")
res1 <- stage1_search(npc_list = npc_list, rep_names = rep_names,
                      metrics = metrics_use, k_grid = k_stage1)

cat("\n[Stage 1 Top 15]\n")
print(head(res1, 15))

cand <- unique(res1[, c("Rep", "nPC", "Metric")])
cand_top <- head(cand, TOP_N_STAGE2)

cat("\n[Stage 2 Candidates]\n")
print(cand_top)

## 8. Stage 2 실행
cat("\n==============================\n")
cat("Stage 2: Refine top candidates (PAM + HClust + KMeans-limited)\n")
cat("==============================\n")
res2 <- stage2_refine(top_candidates = cand_top, k_grid = k_stage2, km_nstart = 60)

cat("\n[Overall Top 20 after Stage 2]\n")
print(head(res2, 20))

best <- res2[1, ]

cat("\n==============================\n")
cat("FINAL BEST (Max Avg Silhouette)\n")
cat("==============================\n")
cat(sprintf("Representation : %s\n", best$Rep))
cat(sprintf("nPC            : %d\n", best$nPC))
cat(sprintf("Metric         : %s\n", best$Metric))
cat(sprintf("Algorithm      : %s\n", best$Method))
cat(sprintf("k              : %d\n", best$k))
cat(sprintf("Avg Silhouette : %.5f\n", best$Score))

## 9. Plot (한 번에 합쳐 출력)
## - Stage2 결과만 시각화(가독성/시간 절약)
plot_df <- res2
plot_df$Key <- paste0(plot_df$Metric, " | ", plot_df$Method)

p_trend <- ggplot(plot_df, aes(x = k, y = Score, color = Key)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.2) +
  facet_wrap(~ Rep, scales = "free_y") +
  theme_bw() +
  labs(title = "Silhouette Trend (Stage 2)", x = "k", y = "Avg Silhouette") +
  theme(legend.position = "bottom", legend.box = "vertical")

## 최종 군집 PC1/PC2 산점도 (PCA 축 % 포함)
Zbest <- pca_fit$x[, 1:best$nPC, drop = FALSE]
Dbest <- make_dist(Zbest, metric = best$Metric)

final_labels <- NULL
if (grepl("^PAM", best$Method)) {
  set.seed(2025)
  pm <- pam(Dbest, k = best$k, diss = TRUE)
  final_labels <- as.factor(pm$clustering)
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
  set.seed(2025)
  km <- kmeans(Zkm, centers = best$k, nstart = 60, iter.max = 300)
  final_labels <- as.factor(km$cluster)
}

viz_df <- data.frame(PC1 = Zbest[, 1], PC2 = Zbest[, 2], Cluster = final_labels)

p_cluster <- ggplot(viz_df, aes(x = PC1, y = PC2, color = Cluster)) +
  geom_point(alpha = 0.6, size = 1.3) +
  theme_bw() +
  labs(
    title = paste0("Final Clusters: ", best$Method, ", k=", best$k),
    subtitle = paste0(best$Rep, " | metric=", best$Metric, " | AvgSil=", sprintf("%.5f", best$Score)),
    x = pc1_lab, y = pc2_lab
  )

final_plot <- cowplot::plot_grid(p_trend, p_cluster, ncol = 1, rel_heights = c(1.2, 1))
print(final_plot)

## 10. Q1 답안(콘솔 출력용)
cat("\n========================================================\n")
cat("[Q1 Answers]\n")
cat("========================================================\n")

cat("(Q1-1) Description of your analysis:\n")
cat("센서 변수 Feature_1~Feature_1211만 사용하여 Z-score 표준화를 수행하였다. ")
cat("하위 주성분에 잡음이 포함되어 군집 분리가 흐릿해질 수 있다는 점을 고려하여, PCA 누적 설명분산 컷(70~95%)과 직접 지정한 nPC 후보를 함께 탐색하였다. ")
cat("각 PCA 표현에서 거리(metric)를 유클리드/맨해튼/코사인으로 바꾸어가며 평균 Silhouette score를 최대화하도록 2단계 탐색을 수행하였다. ")
cat("1단계에서는 PAM(k-medoids)을 거리행렬 기반(diss=TRUE)으로 적용하여 빠르게 상위 후보(표현×거리)를 선별하였다. ")
cat("2단계에서는 상위 후보에 대해 PAM과 계층적 군집(거리 기반 linkage), 그리고 제한적으로 K-means를 비교하고 k 범위를 확장하여 평균 Silhouette score가 최대인 조합을 최종 해로 선택하였다. ")
cat(sprintf("최종적으로 %s(nPC=%d)에서 metric=%s, %s, k=%d가 최대 평균 Silhouette score를 보였다.\n\n",
            best$Rep, best$nPC, best$Metric, best$Method, best$k))

cat("(Q1-2) Average Silhouette score:\n")
cat(sprintf("%.5f\n", best$Score))
cat("========================================================\n")
