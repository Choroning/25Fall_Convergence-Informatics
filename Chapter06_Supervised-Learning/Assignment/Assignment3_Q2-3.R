# @file    Assignment3_Q2-3.R
# @brief   COVID-19 classification sensitivity comparison across 9 ML models with repeated 10-fold CV optimized for sensitivity metric
# @author  Cheolwon Park
# @date    2025-12-05

## 0. 패키지 로드
setRepositories(ind = 1:7)

pkg_list <- c("caret", "e1071", "randomForest", "gbm",
              "xgboost", "klaR", "MASS", "kernlab")
for (p in pkg_list) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
  }
  library(p, character.only = TRUE)
}


## 1. 작업 경로 설정
WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../../data")
if (dir.exists(WORK_DIR)) {
  setwd(WORK_DIR)
} else {
  warning("경로를 확인하세요.")
}


## 2. 데이터 불러오기
data <- read.delim("Data2.tsv",
                   header = TRUE,
                   sep = "\t",
                   check.names = FALSE)


## 3. 라벨 / 피처 준비
## 양성 클래스(positive)를 COVID19로 두기 위해 레벨 순서를 이렇게 설정
data$Disease <- factor(data$Disease,
                       levels = c("COVID19", "Healthy"))

feature_cols <- setdiff(colnames(data), "Disease")
df <- data[, c(feature_cols, "Disease")]

str(df)


## 4. 교차검증 설정 (Sensitivity)
set.seed(2025)

ctrl_sens <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3,
  classProbs = TRUE,          # 확률 필요
  summaryFunction = twoClassSummary,  # ROC, Sens, Spec 계산
  savePredictions = "final"
)


## 5. 모델 학습 (Sensitivity)

model_list <- list()

## 5-1. Logistic Regression
set.seed(2025)
fit_glm <- train(
  Disease ~ .,
  data = df,
  method = "glm",
  family = binomial,
  preProcess = c("center", "scale"),
  trControl = ctrl_sens,
  metric = "Sens"
)
model_list$Logistic <- fit_glm

## 5-2. LDA
set.seed(2025)
fit_lda <- train(
  Disease ~ .,
  data = df,
  method = "lda",
  preProcess = c("center", "scale"),
  trControl = ctrl_sens,
  metric = "Sens"
)
model_list$LDA <- fit_lda

## 5-3. QDA
set.seed(2025)
fit_qda <- train(
  Disease ~ .,
  data = df,
  method = "qda",
  preProcess = c("center", "scale"),
  trControl = ctrl_sens,
  metric = "Sens"
)
model_list$QDA <- fit_qda

## 5-4. k-NN
set.seed(2025)
fit_knn <- train(
  Disease ~ .,
  data = df,
  method = "knn",
  preProcess = c("center", "scale"),
  trControl = ctrl_sens,
  tuneGrid = data.frame(k = seq(3, 25, by = 2)),
  metric = "Sens"
)
model_list$kNN <- fit_knn

## 5-5. Naive Bayes
set.seed(2025)
fit_nb <- train(
  Disease ~ .,
  data = df,
  method = "nb",
  preProcess = c("center", "scale"),
  trControl = ctrl_sens,
  tuneLength = 5,
  metric = "Sens"
)
model_list$NaiveBayes <- fit_nb

## 5-6. Linear SVM
set.seed(2025)
fit_svm_lin <- train(
  Disease ~ .,
  data = df,
  method = "svmLinear",
  preProcess = c("center", "scale"),
  trControl = ctrl_sens,
  tuneGrid = data.frame(C = 2 ^ seq(-5, 5, by = 1)),
  metric = "Sens"
)
model_list$SVM_Linear <- fit_svm_lin

## 5-7. RBF SVM
set.seed(2025)
fit_svm_rbf <- train(
  Disease ~ .,
  data = df,
  method = "svmRadial",
  preProcess = c("center", "scale"),
  trControl = ctrl_sens,
  tuneLength = 10,
  metric = "Sens"
)
model_list$SVM_RBF <- fit_svm_rbf

## 5-8. Random Forest
set.seed(2025)
fit_rf <- train(
  Disease ~ .,
  data = df,
  method = "rf",
  trControl = ctrl_sens,
  tuneGrid = data.frame(mtry = 2:8),
  metric = "Sens"
)
model_list$RandomForest <- fit_rf

## 5-9. Gradient Boosting (GBM)
set.seed(2025)
fit_gbm <- train(
  Disease ~ .,
  data = df,
  method = "gbm",
  trControl = ctrl_sens,
  verbose = FALSE,
  tuneGrid = expand.grid(
    n.trees = c(100, 200, 300),
    interaction.depth = c(1, 3, 5),
    shrinkage = c(0.05, 0.1),
    n.minobsinnode = c(10, 20)
  ),
  metric = "Sens"
)
model_list$GBM <- fit_gbm


## 6. 모델별 최고 Sensitivity 정리

get_best_sens <- function(fit) {
  res <- fit$results
  idx <- which.max(res$Sens)
  return(res$Sens[idx])
}

best_sens <- sapply(model_list, get_best_sens)

result_table <- data.frame(
  Model = names(best_sens),
  BestSensitivity = as.numeric(best_sens)
)

## 민감도 내림차순 정렬
result_table <- result_table[order(-result_table$BestSensitivity), ]

cat("\n=== 모델별 최고 CV Sensitivity (내림차순 정렬) ===\n")
print(result_table, row.names = FALSE)


## 7. 가장 좋은 모델 객체 확인
best_model_name <- result_table$Model[1]
cat("\nSensitivity 기준 최적 모델:", best_model_name, "\n")

best_model <- model_list[[best_model_name]]
print(best_model)
