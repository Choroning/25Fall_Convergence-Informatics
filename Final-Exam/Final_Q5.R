# @file    Final_Q5.R
# @brief   FEV1 prediction (regression) using Elastic Net, Random Forest, GBM, and SVM with PCA-reduced sensor and clinical features
# @author  Cheolwon Park
# @date    2025-12-17

## 0. 환경 설정
setRepositories(ind = 1:7)
rm(list = ls()); gc()

# 필요한 패키지 로드 (openxlsx 포함)
pkg_list <- c("data.table", "caret", "glmnet", "ranger", "gbm", "doParallel", "kernlab", "openxlsx")
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

# 타겟 변수 (연속형)
y <- d1$FEV1_utah
if (is.null(y)) stop("Data1에 FEV1_utah 컬럼이 없습니다.")


## 2. 변수 선정
common_cols <- intersect(colnames(d1), colnames(d2))
x_cols <- setdiff(common_cols, c("sid"))

sensor_cols_all <- grep("^Feature_", colnames(d1), value = TRUE)
sensor_common   <- intersect(sensor_cols_all, x_cols)
clin_common     <- setdiff(x_cols, sensor_common)


## 3. 임상 변수 전처리
clin1 <- d1[, clin_common, drop = FALSE]
clin2 <- d2[, clin_common, drop = FALSE]
clin1$.set <- "train"
clin2$.set <- "test"
clin_all <- rbind(clin1, clin2)

# 상수 변수 제거
const_cols <- sapply(clin_all, function(x) length(unique(x[!is.na(x)])) < 2)
if (any(const_cols)) {
  cols_to_remove <- setdiff(names(which(const_cols)), ".set")
  if(length(cols_to_remove) > 0) clin_all <- clin_all[, !names(clin_all) %in% cols_to_remove]
}

# 타입 재정의
recode_clinical_types <- function(df, max_cat_levels = 10) {
  out <- df
  for (v in names(out)) {
    if (v == ".set") next
    x <- out[[v]]
    if (is.character(x)) { out[[v]] <- as.factor(x); next }
    if (is.factor(x)) next
    if (is.numeric(x)) {
      ux <- sort(unique(x[!is.na(x)]))
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
mm <- model.matrix(~ . - 1, data = clin_all[, !names(clin_all) %in% ".set"])

idx_train <- clin_all$.set == "train"
idx_test  <- clin_all$.set == "test"
Xclin1 <- mm[idx_train, , drop = FALSE]
Xclin2 <- mm[idx_test,  , drop = FALSE]

# NZV 제거
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
pcs_grid <- c(10, 30, 50, 70)
best_pc <- NA; best_rmse <- Inf
ctrl_pc <- trainControl(method = "cv", number = 3)

cat(">> Selecting optimal nPC...\n")
for (kpc in pcs_grid) {
  Z_temp <- pca_fit$x[, 1:kpc, drop = FALSE]
  X_temp <- cbind(Xclin1, Z_temp)
  set.seed(2025)
  fit_tmp <- train(x = X_temp, y = y, method = "glmnet", trControl = ctrl_pc, tuneLength = 3, metric = "RMSE")
  rmse <- min(fit_tmp$results$RMSE)
  if (rmse < best_rmse) { best_rmse <- rmse; best_pc <- kpc }
}
cat(sprintf(">> Selected nPC: %d (Est. RMSE: %.4f)\n", best_pc, best_rmse))

Z1_best <- pca_fit$x[, 1:best_pc, drop = FALSE]
Z2_best <- predict(pca_fit, newdata = Xsen2_sc)[, 1:best_pc, drop = FALSE]

X1 <- cbind(Xclin1, Z1_best)
X2 <- cbind(Xclin2, Z2_best)


## 5. 회귀 모델 학습 (4 Models)
ctrl_cv <- trainControl(method = "cv", number = 5)
model_results <- list()

cat("\n>> Training 4 Regression Models...\n")

# (1) Elastic Net
set.seed(2025)
fit_glmnet <- train(x = X1, y = y, method = "glmnet", trControl = ctrl_cv, tuneLength = 5, metric = "RMSE")
model_results$Glmnet <- min(fit_glmnet$results$RMSE)

# (2) Random Forest
set.seed(2025)
fit_rf <- train(x = X1, y = y, method = "ranger", trControl = ctrl_cv, tuneLength = 3, metric = "RMSE")
model_results$RandomForest <- min(fit_rf$results$RMSE)

# (3) GBM
set.seed(2025)
fit_gbm <- train(x = X1, y = y, method = "gbm", trControl = ctrl_cv, verbose = FALSE, tuneLength = 3, metric = "RMSE")
model_results$GBM <- min(fit_gbm$results$RMSE)

# (4) SVM
set.seed(2025)
fit_svm <- train(x = X1, y = y, method = "svmRadial", trControl = ctrl_cv, preProcess = c("center", "scale"), tuneLength = 3, metric = "RMSE")
model_results$SVM <- min(fit_svm$results$RMSE)


## 6. 최적 모델 선정
scores_df <- data.frame(Model = names(model_results), RMSE = unlist(model_results))
scores_df <- scores_df[order(scores_df$RMSE), ]
print(scores_df)

best_model_name <- scores_df$Model[1]
cat(sprintf(">> Best Model: %s\n", best_model_name))

if(best_model_name == "Glmnet") best_fit <- fit_glmnet
if(best_model_name == "RandomForest") best_fit <- fit_rf
if(best_model_name == "GBM") best_fit <- fit_gbm
if(best_model_name == "SVM") best_fit <- fit_svm


## 7. 예측 및 결과 기입 (XLSX Output)
cat(">> Predicting...\n")
pred_vals <- predict(best_fit, newdata = X2)

ans_path <- "Q5_AnswerSheet.xlsx"
out_path <- "Q5_AnswerSheet_filled.xlsx" # 최종 제출 파일명

# 파일 로드 또는 생성
if (file.exists(ans_path)) {
  cat(">> Loading existing AnswerSheet:", ans_path, "\n")
  wb <- loadWorkbook(ans_path)
  # 첫 번째 시트 읽기
  sheet_name <- names(wb)[1]
  df_ans <- read.xlsx(wb, sheet = 1)
} else {
  cat(">> AnswerSheet not found. Creating a new one based on Data2 sid.\n")
  df_ans <- data.frame(sid = d2$sid, FEV1_utah = NA)
  wb <- createWorkbook()
  addWorksheet(wb, "Sheet1")
}

# sid 매칭 및 값 채우기
# 양식에 따라 컬럼 위치가 다를 수 있으므로 이름으로 확인하거나 2번째 컬럼 사용
target_col_name <- colnames(df_ans)[2]
match_idx <- match(df_ans[, 1], d2$sid) # df_ans의 첫 컬럼(sid)과 Data2의 sid 매칭

df_ans[[target_col_name]][!is.na(match_idx)] <- pred_vals[match_idx[!is.na(match_idx)]]

# 엑셀 파일 저장
writeData(wb, sheet = 1, x = df_ans)
saveWorkbook(wb, out_path, overwrite = TRUE)

stopCluster(cl)
registerDoSEQ()

cat("\n>> Prediction saved to:", out_path, "\n")
cat(">> First 10 predictions:\n")
print(head(df_ans, 10))
