# @file    Final_Q4.R
# @brief   Race prediction (classification) using Glmnet, Random Forest, Multinom, and SVM with PCA-reduced sensor and clinical features
# @author  Cheolwon Park
# @date    2025-12-17

## 0. 환경 설정
setRepositories(ind = 1:7)
rm(list = ls()); gc()

pkg_list <- c("data.table", "caret", "glmnet", "ranger", "nnet", "openxlsx", "doParallel", "kernlab")
for (p in pkg_list) {
  if (!require(p, character.only = TRUE)) {
    tryCatch({
      install.packages(p, repos = "https://cloud.r-project.org")
      library(p, character.only = TRUE)
    }, error = function(e) {
      install.packages(p)
      library(p, character.only = TRUE)
    })
  }
}

set.seed(2025)

WORK_DIR <- "../data"
if (dir.exists(WORK_DIR)) setwd(WORK_DIR)

# 병렬 처리 설정
n_cores <- detectCores() - 1
cl <- makeCluster(n_cores)
registerDoParallel(cl)


## 1. 데이터 로드
cat(">> Loading Data...\n")
d1 <- fread("Data1.tsv", sep = "\t", header = TRUE, data.table = FALSE, check.names = FALSE)
d2 <- fread("Data2_test.tsv", sep = "\t", header = TRUE, data.table = FALSE, check.names = FALSE)

# 타겟 변수
y <- factor(paste0("Class", d1$race))

## 2. 변수 선정
common_cols <- intersect(colnames(d1), colnames(d2))
x_cols <- setdiff(common_cols, c("sid", "race", "FEV1_utah"))

sensor_cols_all <- grep("^Feature_", colnames(d1), value = TRUE)
sensor_common   <- intersect(sensor_cols_all, x_cols)
clin_common     <- setdiff(x_cols, sensor_common)


## 3. 임상 변수 전처리 (에러 수정: 상수 변수 제거)
clin1 <- d1[, clin_common, drop = FALSE]
clin2 <- d2[, clin_common, drop = FALSE]
clin1$.set <- "train"
clin2$.set <- "test"
clin_all <- rbind(clin1, clin2)

# [수정됨] 값이 하나뿐인 상수 변수 제거 (에러 원인 제거)
# NA를 제외하고 유니크한 값이 2개 미만인 컬럼 찾기
const_cols <- sapply(clin_all, function(x) length(unique(x[!is.na(x)])) < 2)
if (any(const_cols)) {
  cat(sprintf(">> Removing %d constant columns from clinical data...\n", sum(const_cols)))
  # .set 컬럼은 지우면 안됨
  cols_to_remove <- setdiff(names(which(const_cols)), ".set")
  if(length(cols_to_remove) > 0){
    clin_all <- clin_all[, !names(clin_all) %in% cols_to_remove]
    print(cols_to_remove)
  }
}

# 타입 재정의 함수
recode_clinical_types <- function(df, max_cat_levels = 10) {
  out <- df
  for (v in names(out)) {
    if (v == ".set") next
    x <- out[[v]]
    if (is.character(x)) { out[[v]] <- as.factor(x); next }
    if (is.factor(x)) next
    if (is.numeric(x)) {
      ux <- sort(unique(x[!is.na(x)]))
      # 값이 0,1 뿐이거나 정수형이면서 레벨이 적으면 범주형
      if ((length(ux) <= 2 && all(ux %in% c(0, 1))) ||
          (length(ux) <= max_cat_levels && all(abs(ux - round(ux)) < 1e-8))) {
        out[[v]] <- factor(x)
      } else {
        out[[v]] <- as.numeric(x)
      }
    }
  }
  return(out)
}

clin_all <- recode_clinical_types(clin_all)

# 원-핫 인코딩
cat(">> Generating Model Matrix...\n")
# .set 컬럼 제외하고 모델 매트릭스 생성
mm <- model.matrix(~ . - 1, data = clin_all[, !names(clin_all) %in% ".set"])

# 다시 분리
idx_train <- clin_all$.set == "train"
idx_test  <- clin_all$.set == "test"
Xclin1 <- mm[idx_train, , drop = FALSE]
Xclin2 <- mm[idx_test,  , drop = FALSE]

# 추가 NZV 제거
nzv_idx <- nearZeroVar(Xclin1)
if(length(nzv_idx) > 0) {
  Xclin1 <- Xclin1[, -nzv_idx, drop = FALSE]
  Xclin2 <- Xclin2[, -nzv_idx, drop = FALSE]
}


## 4. 센서 데이터 PCA
Xsen1 <- as.matrix(d1[, sensor_common, drop = FALSE])
Xsen2 <- as.matrix(d2[, sensor_common, drop = FALSE])

pre_proc_sensor <- preProcess(Xsen1, method = c("center", "scale"))
Xsen1_sc <- predict(pre_proc_sensor, Xsen1)
Xsen2_sc <- predict(pre_proc_sensor, Xsen2)

cat(">> Running PCA on sensors...\n")
pca_fit <- prcomp(Xsen1_sc, center = FALSE, scale. = FALSE)

# nPC 선택 (Grid Search)
pcs_grid <- c(10, 30, 50)
best_pc <- NA; best_acc <- 0
ctrl_pc <- trainControl(method = "cv", number = 3) # 속도를 위해 3-fold

cat(">> Selecting optimal nPC...\n")
for (kpc in pcs_grid) {
  Z_temp <- pca_fit$x[, 1:kpc, drop = FALSE]
  X_temp <- cbind(Xclin1, Z_temp)

  set.seed(2025)
  # 빠른 탐색을 위해 ranger(RF) 사용
  fit_tmp <- train(x = X_temp, y = y, method = "ranger",
                   trControl = ctrl_pc, tuneLength = 1, metric = "Accuracy")

  acc <- max(fit_tmp$results$Accuracy)
  if (acc > best_acc) { best_acc <- acc; best_pc <- kpc }
}
cat(sprintf(">> Selected nPC: %d (Est. Accuracy: %.4f)\n", best_pc, best_acc))

Z1_best <- pca_fit$x[, 1:best_pc, drop = FALSE]
Z2_best <- predict(pca_fit, newdata = Xsen2_sc)[, 1:best_pc, drop = FALSE]

X1 <- cbind(Xclin1, Z1_best)
X2 <- cbind(Xclin2, Z2_best)


## 5. 모델 학습 (4 Models)
ctrl_cv <- trainControl(method = "cv", number = 5, classProbs = TRUE)
model_results <- list()

cat("\n>> Training 4 Models...\n")

# (1) Glmnet
set.seed(2025)
fit_glmnet <- train(x = X1, y = y, method = "glmnet", trControl = ctrl_cv, tuneLength = 5)
model_results$Glmnet <- max(fit_glmnet$results$Accuracy)

# (2) Random Forest
set.seed(2025)
fit_rf <- train(x = X1, y = y, method = "ranger", trControl = ctrl_cv, tuneLength = 3)
model_results$RandomForest <- max(fit_rf$results$Accuracy)

# (3) Multinom
set.seed(2025)
fit_multinom <- train(x = X1, y = y, method = "multinom", trControl = ctrl_cv, trace = FALSE, tuneLength = 3)
model_results$Multinom <- max(fit_multinom$results$Accuracy)

# (4) SVM
set.seed(2025)
fit_svm <- train(x = X1, y = y, method = "svmRadial", trControl = ctrl_cv, preProcess = c("center","scale"), tuneLength = 3)
model_results$SVM <- max(fit_svm$results$Accuracy)


## 6. 결과 저장
scores_df <- data.frame(Model = names(model_results), Accuracy = unlist(model_results))
scores_df <- scores_df[order(-scores_df$Accuracy), ]
print(scores_df)

best_model_name <- scores_df$Model[1]
cat(sprintf(">> Best Model: %s\n", best_model_name))

if(best_model_name == "Glmnet") best_fit <- fit_glmnet
if(best_model_name == "RandomForest") best_fit <- fit_rf
if(best_model_name == "Multinom") best_fit <- fit_multinom
if(best_model_name == "SVM") best_fit <- fit_svm

pred_class <- predict(best_fit, newdata = X2)
pred_final <- as.integer(sub("Class", "", as.character(pred_class)))

# Excel 저장
ans_path <- "Q4_AnswerSheet.xlsx"
out_path <- "Q4_AnswerSheet_filled.xlsx"

if (file.exists(ans_path)) {
  wb <- loadWorkbook(ans_path)
  df_ans <- read.xlsx(wb, sheet = 1)
} else {
  df_ans <- data.frame(sid = d2$sid)
  wb <- createWorkbook()
  addWorksheet(wb, "Sheet1")
}

match_idx <- match(df_ans$sid, d2$sid)
df_ans$race <- NA
df_ans$race[!is.na(match_idx)] <- pred_final[match_idx[!is.na(match_idx)]]

writeData(wb, sheet = 1, x = df_ans)
saveWorkbook(wb, out_path, overwrite = TRUE)

stopCluster(cl)
registerDoSEQ()

cat("\n>> Saved to:", out_path, "\n")
