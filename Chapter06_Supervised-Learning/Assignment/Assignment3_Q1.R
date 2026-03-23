# @file    Assignment3_Q1.R
# @brief   Asthma vs Control classification using LOOCV pipeline with limma feature selection, SMOTE oversampling, and PAMR classifier
# @author  Cheolwon Park
# @date    2025-12-05

## 0. 환경 설정 및 패키지 로드
setRepositories(ind = 1:7)
req_pkgs <- c("caret", "limma", "smotefamily", "pamr", "BiocManager")
for (p in req_pkgs) {
  if (!require(p, character.only = TRUE)) {
    if (p %in% c("limma", "pamr")) {
      if (!require("BiocManager", character.only = TRUE)) {
        install.packages("BiocManager")
        library(BiocManager)
      }
      BiocManager::install(p)
    } else {
      install.packages(p)
    }
    library(p, character.only = TRUE)
  }
}


## 1. 작업 경로 설정
WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../../data")
if (dir.exists(WORK_DIR)) {
  setwd(WORK_DIR)
} else {
  warning("작업 경로를 찾을 수 없습니다. 현재 작업 디렉토리를 사용합니다.")
}


## 2. 데이터 로드 및 전처리
if (file.exists("Data1.tsv")) {
  data1 <- read.delim("Data1.tsv",
                      header = TRUE,
                      sep = "\t",
                      check.names = FALSE)
} else {
  stop("Error: 'Data1.tsv' 파일을 찾을 수 없습니다.")
}

## 2-1. Binary Label 생성 (Asthma vs Control)
sample_id <- data1[, 1]

labels <- ifelse(grepl("Asthma", sample_id, ignore.case = TRUE),
                 "Asthma", "Control")
y <- factor(labels, levels = c("Control", "Asthma"))

## 2-2. Feature Matrix 변환
X_raw <- data1[, -1, drop = FALSE]
X <- data.matrix(X_raw)

## 2-3. NA / Inf 처리
X[is.na(X)] <- 0
X[!is.finite(X)] <- 0

## 2-4. NZV 제거
nzv_idx <- caret::nearZeroVar(X)
if (length(nzv_idx) > 0) {
  X <- X[, -nzv_idx, drop = FALSE]
}

## 정보 (마지막에 출력용)
n_samples  <- nrow(X)
n_features <- ncol(X)
class_table <- table(y)


## 3. LOOCV 파이프라인 (Limma -> SMOTE -> PAMR)
run_pamr_loocv <- function(X, y) {
  n <- nrow(X)
  preds <- character(n)

  set.seed(2025)

  for (i in 1:n) {
    ## 3-1. Train / Test 분리
    train_idx <- setdiff(1:n, i)
    test_idx  <- i

    X_train_curr <- X[train_idx, , drop = FALSE]
    y_train_curr <- y[train_idx]
    X_test_curr  <- X[test_idx,  , drop = FALSE]

    ## 3-2. limma 기반 Feature Selection (Train set only)
    if (length(unique(y_train_curr)) < 2) {
      top_features <- colnames(X_train_curr)
    } else {
      design <- model.matrix(~ y_train_curr)
      fit <- limma::lmFit(t(X_train_curr), design)
      fit <- limma::eBayes(fit)

      top_table <- limma::topTable(
        fit,
        coef = 2,
        number = 20,
        adjust.method = "none",
        sort.by = "P"
      )
      top_features <- rownames(top_table)
    }

    X_train_sel <- X_train_curr[, top_features, drop = FALSE]
    X_test_sel  <- X_test_curr[,  top_features, drop = FALSE]

    ## 3-3. SMOTE로 클래스 불균형 보정
    train_df <- as.data.frame(X_train_sel)
    train_df$class <- y_train_curr

    smote_res <- smotefamily::SMOTE(
      X = train_df[, -ncol(train_df), drop = FALSE],
      target = train_df$class,
      K = 1,
      dup_size = 0
    )

    X_train_smote <- smote_res$data[, -ncol(smote_res$data), drop = FALSE]
    y_train_smote <- as.factor(smote_res$data[, ncol(smote_res$data)])

    X_train_final <- data.matrix(X_train_smote)

    ## 3-4. PAMR 학습
    pam_data <- list(
      x = t(X_train_final),
      y = y_train_smote,
      geneid = colnames(X_train_final)
    )

    capture.output({
      pam_fit <- pamr::pamr.train(pam_data, threshold = NULL)
    })

    ## threshold 벡터의 마지막 값 사용
    best_threshold <- pam_fit$threshold[length(pam_fit$threshold)]

    pred_i <- pamr::pamr.predict(
      pam_fit,
      newx = t(X_test_sel),
      threshold = best_threshold,
      type = "class"
    )

    preds[i] <- as.character(pred_i)
  }

  return(preds)
}


## 4. LOOCV 실행
final_pred <- run_pamr_loocv(X, y)


## 5. 결과 정리 및 한 번에 출력
result_df <- data.frame(
  SampleID  = sample_id,
  Actual    = as.character(y),
  Predicted = final_pred,
  Correct   = (as.character(y) == final_pred),
  stringsAsFactors = FALSE
)

acc <- mean(result_df$Correct)
cm  <- table(Truth = y, Pred = final_pred)

if ("Asthma" %in% rownames(cm) && "Asthma" %in% colnames(cm)) {
  sens <- cm["Asthma", "Asthma"] / sum(cm["Asthma", ])
} else {
  sens <- NA
}



## 결과 출력
cat("======================================================\n [Data Summary]\n======================================================\n")
cat(sprintf("- #Samples:  %d\n", n_samples))
cat(sprintf("- #Features: %d\n", n_features))
cat("- Class Distribution:\n")
print(class_table)

cat("\n======================================================\n [LOOCV Prediction Results]\n======================================================\n")
print(result_df)

cat("\n======================================================\n [Performance Summary]\n======================================================\n\n- Confusion Matrix (LOOCV):\n")
print(cm)

cat(sprintf("\n- LOOCV Total Accuracy: %.2f%%\n", acc * 100))

if (!is.na(sens)) {
  cat(sprintf("- Asthma Sensitivity: %.2f%%\n", sens * 100))
} else {
  cat("- Asthma Sensitivity: 계산 불가 (Asthma 예측 없음)\n")
}

cat("\n- 모든 작업이 완료되었습니다.\n")
