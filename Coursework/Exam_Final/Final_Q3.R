# @file    Final_Q3.R
# @brief   Clinical interpretation of clusters via univariate tests, Random Forest importance, and post-hoc pairwise comparisons
# @author  Cheolwon Park
# @date    2025-12-17

## 1. 기본 환경 설정
setRepositories(ind = 1:7)

pkg_list <- c("data.table", "cluster", "ranger")
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

## -----------------------------------------------------
## 3. Q1 최적 군집 재현: (PC3, cosine distance, KMeans, k=3)
## -----------------------------------------------------
cat(">> Reproducing Q1 best clustering (PC3 + cosine + KMeans + k=3)...\n")

sensor_cols <- grep("^Feature_", colnames(d1), value = TRUE)
X_raw <- d1[, sensor_cols, drop = FALSE]
X_scaled <- scale(X_raw)

pca_fit <- prcomp(X_scaled, center = FALSE, scale. = FALSE)
Zbest <- pca_fit$x[, 1:3, drop = FALSE]  # nPC=3

make_dist_cosine <- function(Z) {
  rn <- sqrt(rowSums(Z^2))
  rn[rn == 0] <- 1
  Zn <- Z / rn
  sim <- Zn %*% t(Zn)
  dmat <- 1 - sim
  diag(dmat) <- 0
  rm(sim); gc()
  as.dist(dmat)
}

Dbest <- make_dist_cosine(Zbest)

## cosine 목적에 맞게 row-normalize 후 kmeans
Zkm <- Zbest
rn <- sqrt(rowSums(Zkm^2)); rn[rn == 0] <- 1
Zkm <- Zkm / rn

set.seed(2025)
km <- kmeans(Zkm, centers = 3, nstart = 60, iter.max = 300)
cluster <- factor(km$cluster)

sil <- silhouette(as.integer(cluster), Dbest)
avg_sil <- mean(sil[, 3])

cat("\n[Check] Q1 best reproduced\n")
cat(sprintf(" - Overall mean silhouette: %.5f\n", avg_sil))
cat(sprintf(" - Cluster sizes: %s\n", paste(table(cluster), collapse = ", ")))

## -----------------------------------------------------
## 4. 임상 변수(123개) 분리 + 타입 재분류(해석력 향상)
## -----------------------------------------------------
clinical_cols_all <- setdiff(colnames(d1), c("sid", sensor_cols))
clin_raw <- d1[, clinical_cols_all, drop = FALSE]

recode_clinical_types <- function(df, max_cat_levels = 10) {
  out <- df
  type_map <- data.frame(Variable = names(df),
                         InferredType = NA_character_,
                         stringsAsFactors = FALSE)

  for (v in names(out)) {
    x <- out[[v]]

    if (is.character(x)) {
      out[[v]] <- as.factor(x)
      type_map$InferredType[type_map$Variable == v] <- "Categorical(character)"
      next
    }

    if (is.factor(x)) {
      type_map$InferredType[type_map$Variable == v] <- "Categorical(factor)"
      next
    }

    if (is.integer(x) || is.numeric(x)) {
      ux <- sort(unique(x[!is.na(x)]))
      n_ux <- length(ux)

      ## 0/1 이진
      if (n_ux <= 2 && all(ux %in% c(0, 1))) {
        out[[v]] <- factor(x)
        type_map$InferredType[type_map$Variable == v] <- "Binary(0/1)"
        next
      }

      ## 소수 수준의 정수(범주형 가능성)
      if (n_ux <= max_cat_levels && all(abs(ux - round(ux)) < 1e-8)) {
        out[[v]] <- factor(x)
        type_map$InferredType[type_map$Variable == v] <- paste0("Categorical(int<= ", max_cat_levels, ")")
        next
      }

      ## 그 외는 numeric
      out[[v]] <- as.numeric(x)
      type_map$InferredType[type_map$Variable == v] <- "Numeric"
      next
    }

    ## 기타 타입은 factor 처리
    out[[v]] <- as.factor(x)
    type_map$InferredType[type_map$Variable == v] <- "Categorical(other)"
  }

  list(df = out, type_map = type_map)
}

tmp <- recode_clinical_types(clin_raw, max_cat_levels = 10)
clin <- tmp$df
type_map <- tmp$type_map

cat("\n[Clinical type inference summary]\n")
print(table(type_map$InferredType, useNA = "ifany"))

## avail 변수 분리(가용성/측정여부 성격)
avail_vars <- grep("avail", names(clin), ignore.case = TRUE, value = TRUE)
clin_main_vars <- setdiff(names(clin), avail_vars)

cat("\n[Availability-like variables flagged]\n")
if (length(avail_vars) == 0) {
  cat(" - None detected by name pattern 'avail'\n")
} else {
  cat(sprintf(" - %d variables flagged: %s\n", length(avail_vars), paste(avail_vars, collapse = ", ")))
}

## -----------------------------------------------------
## 5. 단변량(클러스터 차이) + 효과크기 + 보정(BH-FDR)
##    + (추가) 사후검정(pairwise)까지 수행
## -----------------------------------------------------
get_eps_sq_kw <- function(kw_stat, k, n) {
  ## epsilon^2 = (H - k + 1) / (n - k)
  if (is.na(kw_stat)) return(NA_real_)
  if (n <= k) return(NA_real_)
  as.numeric((kw_stat - k + 1) / (n - k))
}

get_cramers_v <- function(tab) {
  chi <- suppressWarnings(chisq.test(tab, correct = FALSE))
  n <- sum(tab)
  r <- nrow(tab); c <- ncol(tab)
  denom <- n * (min(r - 1, c - 1))
  if (denom <= 0) return(NA_real_)
  as.numeric(sqrt(chi$statistic / denom))
}

one_univariate <- function(x, g) {
  ok <- complete.cases(x, g)
  x2 <- x[ok]
  g2 <- g[ok]
  if (length(unique(x2)) < 2) return(NULL)

  if (is.numeric(x2)) {
    kt <- suppressWarnings(kruskal.test(x2 ~ g2))
    p <- as.numeric(kt$p.value)
    eff <- get_eps_sq_kw(as.numeric(kt$statistic), k = length(levels(g2)), n = length(x2))
    data.frame(P_value = p, Effect = eff, Test = "KruskalWallis(eps^2)", stringsAsFactors = FALSE)
  } else {
    tab <- table(x2, g2)
    tab <- tab[rowSums(tab) > 0, colSums(tab) > 0, drop = FALSE]
    if (nrow(tab) < 2 || ncol(tab) < 2) return(NULL)

    cs <- suppressWarnings(chisq.test(tab, correct = FALSE))
    exp_min <- suppressWarnings(min(cs$expected))

    if (is.finite(exp_min) && exp_min < 5) {
      cs2 <- suppressWarnings(chisq.test(tab, correct = FALSE, simulate.p.value = TRUE, B = 2000))
      p <- as.numeric(cs2$p.value)
      test_name <- "ChiSquare(simulated)"
    } else {
      p <- as.numeric(cs$p.value)
      test_name <- "ChiSquare"
    }

    eff <- get_cramers_v(tab)
    data.frame(P_value = p, Effect = eff, Test = paste0(test_name, "(CramersV)"), stringsAsFactors = FALSE)
  }
}

run_univariate <- function(df, vars, g) {
  out <- data.frame()
  for (v in vars) {
    r <- one_univariate(df[[v]], g)
    if (is.null(r)) next
    out <- rbind(out, data.frame(
      Variable = v,
      InferredType = type_map$InferredType[type_map$Variable == v][1],
      P_value = r$P_value,
      AdjP_BH = NA_real_,
      Effect = r$Effect,
      Test = r$Test,
      stringsAsFactors = FALSE
    ))
  }
  out$AdjP_BH <- p.adjust(out$P_value, method = "BH")
  out[order(out$AdjP_BH, out$P_value), ]
}

cat("\n>> Univariate tests on MAIN clinical vars (excluding 'avail')...\n")
uni_main <- run_univariate(clin, clin_main_vars, cluster)

cat("\n>> Univariate tests on AVAIL-like vars (reported separately)...\n")
uni_avail <- if (length(avail_vars) > 0) run_univariate(clin, avail_vars, cluster) else data.frame()

cat("\n========================================================\n")
cat("[Q3] Univariate results (MAIN) - Top 20 by BH-FDR\n")
cat("========================================================\n")
print(head(uni_main, 20))

cat("\n========================================================\n")
cat("[Q3] MAIN vars significant at BH-FDR < 0.05 (count)\n")
cat("========================================================\n")
cat(sum(uni_main$AdjP_BH < 0.05), "\n")

if (nrow(uni_avail) > 0) {
  cat("\n========================================================\n")
  cat("[Q3] Univariate results (AVAIL-like vars) - All\n")
  cat("========================================================\n")
  print(uni_avail)

  cat("\n========================================================\n")
  cat("[Q3] AVAIL-like vars significant at BH-FDR < 0.05 (count)\n")
  cat("========================================================\n")
  cat(sum(uni_avail$AdjP_BH < 0.05), "\n")
}

## ---------------------------
## (추가) 사후검정: pairwise 비교
## - Numeric: pairwise Wilcoxon (BH)
## - Categorical: 각 쌍에 대해 chisq / fisher(simulate)로 p 계산 후 BH
## - 출력은 상위 후보 변수에 한정(시간 절약)
## ---------------------------
pairwise_cat_p <- function(x, g) {
  ok <- complete.cases(x, g)
  x2 <- x[ok]; g2 <- g[ok]
  levs <- levels(g2)
  pairs <- combn(levs, 2, simplify = FALSE)

  out <- data.frame(contrast = character(), p_value = numeric(), stringsAsFactors = FALSE)

  for (pp in pairs) {
    gA <- pp[1]; gB <- pp[2]
    sel <- g2 %in% c(gA, gB)
    xx <- droplevels(x2[sel])
    gg <- droplevels(g2[sel])

    tab <- table(xx, gg)
    tab <- tab[rowSums(tab) > 0, colSums(tab) > 0, drop = FALSE]
    if (nrow(tab) < 2 || ncol(tab) < 2) next

    ## 2x2 이면서 희소하면 fisher, 아니면 chisq(필요 시 simulate)
    if (nrow(tab) == 2 && ncol(tab) == 2) {
      cs <- suppressWarnings(chisq.test(tab, correct = FALSE))
      exp_min <- suppressWarnings(min(cs$expected))
      if (is.finite(exp_min) && exp_min < 5) {
        ft <- suppressWarnings(fisher.test(tab))
        p <- as.numeric(ft$p.value)
      } else {
        p <- as.numeric(cs$p.value)
      }
    } else {
      cs <- suppressWarnings(chisq.test(tab, correct = FALSE))
      exp_min <- suppressWarnings(min(cs$expected))
      if (is.finite(exp_min) && exp_min < 5) {
        cs2 <- suppressWarnings(chisq.test(tab, correct = FALSE, simulate.p.value = TRUE, B = 5000))
        p <- as.numeric(cs2$p.value)
      } else {
        p <- as.numeric(cs$p.value)
      }
    }

    out <- rbind(out, data.frame(contrast = paste0(gA, " vs ", gB), p_value = p, stringsAsFactors = FALSE))
  }

  if (nrow(out) > 0) out$p_adj_BH <- p.adjust(out$p_value, method = "BH")
  out
}

pairwise_num_p <- function(x, g) {
  ok <- complete.cases(x, g)
  x2 <- x[ok]; g2 <- g[ok]
  pw <- pairwise.wilcox.test(x2, g2, p.adjust.method = "BH", exact = FALSE)
  ## matrix -> long
  m <- pw$p.value
  if (is.null(m)) return(data.frame())
  res <- data.frame()
  rn <- rownames(m); cn <- colnames(m)
  for (i in seq_along(rn)) {
    for (j in seq_along(cn)) {
      if (!is.na(m[i, j])) {
        res <- rbind(res, data.frame(
          contrast = paste0(rn[i], " vs ", cn[j]),
          p_adj_BH = as.numeric(m[i, j]),
          stringsAsFactors = FALSE
        ))
      }
    }
  }
  res
}

## 후보 변수 선정: (1) uni_main 상위 + (2) RF 중요도 상위의 합집합으로 가져가되,
## 사후검정은 상위 N개만 수행(시간 제한)
top_uni_n <- 20

## -----------------------------------------------------
## 6. 다변량(Random Forest) + (추가) permutation test로 유의성 검증
## -----------------------------------------------------
cat("\n>> Multivariate modeling (Random Forest) using MAIN clinical vars...\n")

df_model <- data.frame(cluster = cluster, clin[, clin_main_vars, drop = FALSE])
cc <- complete.cases(df_model)
df_model_cc <- df_model[cc, , drop = FALSE]

cat(sprintf(" - Complete-case rows for RF: %d / %d\n", nrow(df_model_cc), nrow(df_model)))
cat(sprintf(" - Class distribution: %s\n", paste(table(df_model_cc$cluster), collapse = ", ")))

## 5-fold CV folds (고정)
kfold <- 5
set.seed(2025)
fold_id <- sample(rep(1:kfold, length.out = nrow(df_model_cc)))

rf_cv_acc <- function(y_vec, data_x, fold_id, num.trees = 300, seed_base = 2025) {
  acc <- numeric(max(fold_id))
  for (f in 1:max(fold_id)) {
    tr <- data_x[fold_id != f, , drop = FALSE]
    te <- data_x[fold_id == f, , drop = FALSE]

    tr$cluster <- y_vec[fold_id != f]
    te$cluster <- y_vec[fold_id == f]

    tr$cluster <- factor(tr$cluster)
    te$cluster <- factor(te$cluster, levels = levels(tr$cluster))

    set.seed(seed_base + f)
    rf_fit <- ranger(cluster ~ .,
                     data = tr,
                     num.trees = num.trees,
                     importance = "impurity",
                     probability = FALSE)
    pred <- predict(rf_fit, data = te)$predictions
    acc[f] <- mean(pred == te$cluster)
    rm(rf_fit); gc()
  }
  acc
}

## 관측 CV
y_obs <- df_model_cc$cluster
x_obs <- df_model_cc[, setdiff(names(df_model_cc), "cluster"), drop = FALSE]

acc_obs <- rf_cv_acc(y_vec = y_obs, data_x = x_obs, fold_id = fold_id, num.trees = 300, seed_base = 2025)
cv_acc_mean <- mean(acc_obs)
cv_acc_sd <- sd(acc_obs)

cat("\n[RF 5-fold CV]\n")
cat(sprintf(" - Accuracy (mean +/- sd): %.4f +/- %.4f\n", cv_acc_mean, cv_acc_sd))
cat(sprintf(" - Fold accuracies: %s\n", paste(round(acc_obs, 4), collapse = ", ")))

## baseline(다수 클래스)
majority_acc <- max(prop.table(table(y_obs)))
cat(sprintf(" - Baseline majority-class accuracy: %.4f\n", majority_acc))
cat(sprintf(" - Baseline random(1/3) accuracy: %.4f\n", 1/length(levels(y_obs))))

## (추가) Permutation test: 라벨 셔플했을 때의 CV 정확도 분포
B_perm <- 200  # 시간 절충(필요 시 100~500 조절)
cat("\n[Permutation test for RF CV accuracy]\n")
cat(sprintf(" - B = %d permutations (same folds), trees(permuted)=200\n", B_perm))

set.seed(2025)
acc_null <- numeric(B_perm)

for (b in 1:B_perm) {
  set.seed(2025 + b)
  y_perm <- sample(y_obs, replace = FALSE)
  acc_b <- rf_cv_acc(y_vec = y_perm, data_x = x_obs, fold_id = fold_id, num.trees = 200, seed_base = 6000 + b*10)
  acc_null[b] <- mean(acc_b)
  if (b %% 20 == 0) cat(sprintf("  ... %d/%d done (null mean so far: %.4f)\n", b, B_perm, mean(acc_null[1:b])))
}

p_perm <- (1 + sum(acc_null >= cv_acc_mean)) / (B_perm + 1)
cat(sprintf(" - Observed CV accuracy mean: %.4f\n", cv_acc_mean))
cat(sprintf(" - Null CV accuracy mean (perm): %.4f (sd=%.4f)\n", mean(acc_null), sd(acc_null)))
cat(sprintf(" - Permutation p-value (Pr[null >= observed]): %.5f\n", p_perm))

## 최종 RF 학습(전체) + 중요도
set.seed(2025)
rf_final <- ranger(cluster ~ .,
                   data = df_model_cc,
                   num.trees = 800,
                   importance = "impurity",
                   probability = FALSE)

imp <- sort(rf_final$variable.importance, decreasing = TRUE)
imp_df <- data.frame(Variable = names(imp),
                     RF_Importance = as.numeric(imp),
                     stringsAsFactors = FALSE)

cat("\n========================================================\n")
cat("[Q3] Multivariate variable importance (RF) - Top 20\n")
cat("========================================================\n")
print(head(imp_df, 20))

## -----------------------------------------------------
## 7. 단변량 + 다변량 결합 근거 테이블 + (추가) 사후검정 출력
## -----------------------------------------------------
cand_vars <- unique(c(head(uni_main$Variable, top_uni_n),
                      head(imp_df$Variable, 20)))

sum_tbl <- merge(uni_main[, c("Variable", "InferredType", "P_value", "AdjP_BH", "Effect", "Test")],
                 imp_df, by = "Variable", all.x = TRUE)

sum_tbl <- sum_tbl[sum_tbl$Variable %in% cand_vars, , drop = FALSE]
sum_tbl <- sum_tbl[order(sum_tbl$AdjP_BH, -sum_tbl$RF_Importance), ]

cat("\n========================================================\n")
cat("[Q3] Combined evidence table (Univariate + RF importance) - Candidates\n")
cat("========================================================\n")
print(sum_tbl)

## (추가) 상위 후보 변수에 대한 클러스터별 프로파일 + pairwise 검정
profile_n <- 12
profile_vars <- head(sum_tbl$Variable, profile_n)

cat("\n========================================================\n")
cat("[Q3] Cluster-wise profiles + post-hoc pairwise tests (Top candidates)\n")
cat("========================================================\n")

for (v in profile_vars) {
  x <- clin[[v]]
  ok <- complete.cases(x, cluster)
  x2 <- x[ok]
  g2 <- cluster[ok]

  cat("\n----------------------------------------\n")
  cat(sprintf("Variable: %s | Type: %s\n", v, type_map$InferredType[type_map$Variable == v][1]))

  st <- sum_tbl[sum_tbl$Variable == v, , drop = FALSE]
  if (nrow(st) == 1) {
    cat(sprintf(" - Univariate: p=%.3g | adj(BH)=%.3g | Effect=%.4f | Test=%s\n",
                st$P_value, st$AdjP_BH, st$Effect, st$Test))
    if (!is.na(st$RF_Importance)) {
      cat(sprintf(" - RF importance (impurity): %.4f\n", st$RF_Importance))
    }
  }

  if (is.numeric(x2)) {
    df <- data.frame(x = x2, cl = g2)
    agg_mean <- aggregate(x ~ cl, df, mean)
    agg_sd   <- aggregate(x ~ cl, df, sd)

    cat("Cluster means:\n"); print(agg_mean)
    cat("Cluster sds:\n");   print(agg_sd)

    pw <- pairwise_num_p(x2, g2)
    if (nrow(pw) > 0) {
      cat("Post-hoc pairwise Wilcoxon (BH-adjusted p):\n")
      print(pw)
    } else {
      cat("Post-hoc pairwise Wilcoxon: not available.\n")
    }

  } else {
    ## 범주형: within-cluster proportion
    tab_prop <- prop.table(table(x2, g2), margin = 2)
    cat("Cluster proportions (within each cluster):\n")
    print(round(tab_prop, 3))

    pwc <- pairwise_cat_p(x2, g2)
    if (nrow(pwc) > 0) {
      cat("Post-hoc pairwise categorical tests (BH-adjusted within-variable):\n")
      print(pwc)
    } else {
      cat("Post-hoc pairwise categorical tests: not available.\n")
    }
  }
}

## -----------------------------------------------------
## 8. Q3 작성에 바로 쓰기 좋은 핵심 요약(콘솔)
## -----------------------------------------------------
cat("\n========================================================\n")
cat("[Q3] Key summary for writing answers\n")
cat("========================================================\n")

cat(sprintf("1) Clustering validity check: overall mean silhouette = %.5f\n", avg_sil))
cat(sprintf("2) MAIN clinical vars (excluding 'avail'): BH-FDR<0.05 count = %d\n", sum(uni_main$AdjP_BH < 0.05)))
if (nrow(uni_avail) > 0) {
  cat(sprintf("3) AVAIL-like vars: BH-FDR<0.05 count = %d (not recommended as clinical interpretation)\n", sum(uni_avail$AdjP_BH < 0.05)))
  cat("   - Significant AVAIL-like vars:\n")
  print(uni_avail[uni_avail$AdjP_BH < 0.05, ])
}

cat(sprintf("4) RF (MAIN vars) 5-fold CV accuracy = %.4f +/- %.4f (baseline majority=%.4f)\n",
            cv_acc_mean, cv_acc_sd, majority_acc))
cat(sprintf("5) RF permutation test p-value = %.5f (B=%d)\n", p_perm, B_perm))

cat("\n>> Done.")
