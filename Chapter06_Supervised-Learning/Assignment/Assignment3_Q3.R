# @file    Assignment3_Q3.R
# @brief   DNA forensic matching to identify a serial killer suspect using Hamming distance, Euclidean distance, and PCA visualization on DNA marker database
# @author  Cheolwon Park
# @date    2025-12-06

## 0. 패키지 로드
setRepositories(ind = 1:7)

pkg_list <- c("ggplot2", "dplyr", "ggrepel")
for (p in pkg_list) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
    library(p, character.only = TRUE)
  }
}

library(dplyr)


## 1. 작업 경로 설정

WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../../data")
if (dir.exists(WORK_DIR)) {
  setwd(WORK_DIR)
} else {
  warning("작업 경로를 찾을 수 없습니다. 현재 작업 디렉토리를 사용합니다.")
}


## 2. 데이터 불러오기
db    <- read.csv("Data3_DNA_Database.csv",
                  header = TRUE,
                  stringsAsFactors = FALSE)
query <- read.csv("Data3_DNA_Query.csv",
                  header = TRUE,
                  stringsAsFactors = FALSE)

## Subject: 개체 ID, DNA_1 ~ DNA_1000: DNA 마커라고 가정
feature_cols <- grep("^DNA_", colnames(db), value = TRUE)

X_db <- as.matrix(db[, feature_cols])
x_q  <- as.numeric(query[1, feature_cols])

n_db <- nrow(X_db)
p    <- ncol(X_db)


## 3. 쿼리 샘플과의 유사도 계산
##  - Matches: 완전히 동일한 DNA 마커 개수
##  - Hamming: 서로 다른 마커 개수 (p - Matches)
##  - Euclidean: 유클리드 거리 (참고용)
same_mat <- X_db == matrix(rep(x_q, each = n_db),
                           nrow = n_db)

matches <- rowSums(same_mat)
hamming <- p - matches

diff_mat <- sweep(X_db, 2, x_q, FUN = "-")
euclid  <- sqrt(rowSums(diff_mat^2))

score_df <- data.frame(
  Subject = db$Subject,
  Matches = matches,
  Hamming = hamming,
  Euclid  = euclid,
  stringsAsFactors = FALSE
)


## 4. 최적 후보(연쇄살인범) 및 2등 후보 식별
## Hamming 거리가 작을수록, Matches가 클수록 쿼리와 유사
best_idx       <- which.min(score_df$Hamming)  # Hamming 기준 최솟값
best_subject   <- score_df$Subject[best_idx]

## 두 번째로 가까운 후보
hamming_order  <- order(score_df$Hamming, score_df$Euclid)
second_idx     <- hamming_order[2]
second_subject <- score_df$Subject[second_idx]

score_df$IsBest   <- score_df$Subject == best_subject
score_df$IsSecond <- score_df$Subject == second_subject

## 요약 통계
mean_matches <- mean(score_df$Matches)
sd_matches   <- sd(score_df$Matches)

mean_hamming <- mean(score_df$Hamming)
sd_hamming   <- sd(score_df$Hamming)


## 5. 텍스트 요약 출력
cat("======================================================\n")
cat(" [Q3 DNA Matching - Summary]\n")
cat("======================================================\n")
cat(sprintf("- #Database Individuals: %d\n", n_db))
cat(sprintf("- #DNA Markers (features): %d\n\n", p))

cat("- Matches with Query:\n")
cat(sprintf("  * Mean matches:  %.2f\n", mean_matches))
cat(sprintf("  * SD of matches: %.2f\n\n", sd_matches))

cat("- Best Match Candidate (Hamming distance 기준 1등):\n")
cat(sprintf("  * Subject ID: %s\n", best_subject))
cat(sprintf("  * #Matched markers: %d / %d\n",
            score_df$Matches[best_idx], p))
cat(sprintf("  * #Mismatched markers (Hamming): %d\n",
            score_df$Hamming[best_idx]))
cat(sprintf("  * Euclidean distance: %.4f\n\n",
            score_df$Euclid[best_idx]))

cat("- Second Best Candidate (Hamming distance 기준 2등):\n")
cat(sprintf("  * Subject ID: %s\n", second_subject))
cat(sprintf("  * #Matched markers: %d / %d\n",
            score_df$Matches[second_idx], p))
cat(sprintf("  * #Mismatched markers (Hamming): %d\n",
            score_df$Hamming[second_idx]))
cat(sprintf("  * Euclidean distance: %.4f\n\n",
            score_df$Euclid[second_idx]))


## 6. 시각화 1: Hamming 거리 정렬 플롯 (원래 거리)
##  - x축: 쿼리와의 거리 순위 (1등이 맨 왼쪽)
##  - y축: Hamming 거리 (작을수록 유사)
dist_ranked <- score_df %>%
  arrange(Hamming) %>%
  mutate(Rank = row_number())

p_dist <- ggplot(dist_ranked,
                 aes(x = Rank, y = Hamming)) +
  geom_line(alpha = 0.6) +
  geom_point(alpha = 0.6, size = 1.5) +
  geom_point(data = subset(dist_ranked, Subject == best_subject),
             aes(x = Rank, y = Hamming),
             color = "red", size = 3) +
  geom_point(data = subset(dist_ranked, Subject == second_subject),
             aes(x = Rank, y = Hamming),
             color = "blue", size = 3) +
  ggrepel::geom_text_repel(
    data = subset(dist_ranked, Subject %in% c(best_subject, second_subject)),
    aes(label = Subject),
    nudge_y = 10,
    size = 3,
    show.legend = FALSE
  ) +
  labs(
    title = "Hamming Distance to Query (sorted by Rank)",
    x = "Rank (1 = closest to query)",
    y = "Hamming distance (# of mismatched markers)"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5)
  )

print(p_dist)


## 7. 시각화 2: Hamming 거리 분포 + Best / Second 위치
p_hist <- ggplot(score_df, aes(x = Hamming)) +
  geom_histogram(binwidth = max(1, floor(sd_hamming / 2)),
                 fill = "grey80", color = "black") +
  geom_vline(xintercept = score_df$Hamming[best_idx],
             color = "red", linewidth = 1.0) +
  geom_vline(xintercept = score_df$Hamming[second_idx],
             color = "blue", linetype = "dashed", linewidth = 1.0) +
  annotate("text",
           x = score_df$Hamming[best_idx],
           y = Inf, vjust = 1.5,
           label = paste0("Best: ", best_subject),
           color = "red", size = 3) +
  annotate("text",
           x = score_df$Hamming[second_idx],
           y = Inf, vjust = 3.0,
           label = paste0("2nd: ", second_subject),
           color = "blue", size = 3) +
  labs(
    title = "Distribution of Hamming Distances to Query",
    x = "Hamming distance (# of mismatched markers)",
    y = "Count"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5)
  )

print(p_hist)


## 8. 시각화 3: Top N 일치 마커 개수 막대그래프
top_n <- 30

score_ranked <- score_df %>%
  arrange(desc(Matches)) %>%
  mutate(Rank = row_number())

top_scores <- score_ranked[1:top_n, ]
top_scores$SubjectLabel <- factor(top_scores$Subject,
                                  levels = rev(top_scores$Subject))

p_top <- ggplot(top_scores,
                aes(x = SubjectLabel, y = Matches,
                    fill = Subject == best_subject)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c(`TRUE` = "red", `FALSE` = "grey70")) +
  labs(
    title = paste0("Top ", top_n, " DNA Matches with Query"),
    x = "Subject",
    y = "# of identical DNA markers",
    fill = "Best Match"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = "bottom"
  )

print(p_top)


## 9. 시각화 4: PCA 산점도
X_all <- rbind(X_db, x_q)  # (n_db + 1) x p

pca_all <- prcomp(X_all, center = TRUE, scale. = TRUE)
var_exp <- pca_all$sdev^2 / sum(pca_all$sdev^2)

pc_df <- data.frame(
  PC1 = pca_all$x[, 1],
  PC2 = pca_all$x[, 2],
  Type = c(rep("Database", n_db), "Query"),
  Subject = c(db$Subject, query$Subject[1]),
  stringsAsFactors = FALSE
)

pc_df$Group <- "Others"
pc_df$Group[best_idx] <- "BestMatch"
pc_df$Group[n_db + 1] <- "Query"

p_pca <- ggplot(pc_df,
                aes(x = PC1, y = PC2,
                    color = Group, shape = Group)) +
  geom_point(alpha = 0.7, size = 1.5) +
  ggrepel::geom_text_repel(
    data = subset(pc_df, Group != "Others"),
    aes(label = Subject),
    size = 3,
    show.legend = FALSE
  ) +
  labs(
    title = "PCA of DNA Profiles (Database + Query)",
    x = paste0("PC1 (", round(var_exp[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(var_exp[2] * 100, 1), "%)"),
    color = "Group",
    shape = "Group"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5)
  )

print(p_pca)

cat("======================================================\n")
cat("분석 및 모든 시각화가 완료되었습니다.\n")
cat(sprintf("쿼리 DNA와 가장 유사한 개체는 '%s'입니다.\n", best_subject))
cat("======================================================\n")
