# HW3 Code Walkthrough — Supervised Learning

[Repository Guide](../../README.md) | [English](Code-Walkthrough.md) | [한국어](Code-Walkthrough.ko.md)

> **Last Updated:** 2026-11-17

> **Learning Objectives:**
> 1. Read code that performs limma feature selection, SMOTE, and PAMR training and prediction in turn inside a LOOCV loop, and explain the input and output of each step
> 2. Train several models on the same cross-validation splits with caret's `trainControl()` and `train()`, and extract the best value of each metric from the result tables
> 3. Compute the number of matches and the distances between one vector and a whole database at once with element-wise matrix comparison, `rowSums()`, and `sweep()`
> 4. Build rank plots, histograms, bar charts, and scatter plots with dplyr, ggplot2, ggrepel, and cowplot, and highlight specific individuals

---

## Table of Contents

- [1. File Structure and How to Run](#1-file-structure-and-how-to-run)
- [2. Parts Common to the Five Scripts](#2-parts-common-to-the-five-scripts)
- [3. Assignment3_Q1.R: LOOCV Classification Pipeline](#3-assignment3_q1r-loocv-classification-pipeline)
  - [3.1 Labels and Feature Matrix](#31-labels-and-feature-matrix)
  - [3.2 Splitting the Training Set and the Validation Sample](#32-splitting-the-training-set-and-the-validation-sample)
  - [3.3 limma Feature Selection](#33-limma-feature-selection)
  - [3.4 SMOTE](#34-smote)
  - [3.5 PAMR Training and Prediction](#35-pamr-training-and-prediction)
  - [3.6 Collecting and Printing the Results](#36-collecting-and-printing-the-results)
- [4. Assignment3_Q2-1.R: Three Two-Dimensional Visualizations](#4-assignment3_q2-1r-three-two-dimensional-visualizations)
- [5. Assignment3_Q2-2.R: Model Comparison by Accuracy](#5-assignment3_q2-2r-model-comparison-by-accuracy)
  - [5.1 Cross-Validation Setup](#51-cross-validation-setup)
  - [5.2 Model Training](#52-model-training)
  - [5.3 Best Accuracy of Each Model](#53-best-accuracy-of-each-model)
- [6. Assignment3_Q2-3.R: Changes for the Sensitivity Criterion](#6-assignment3_q2-3r-changes-for-the-sensitivity-criterion)
- [7. Assignment3_Q3.R: DNA Match Search](#7-assignment3_q3r-dna-match-search)
  - [7.1 Data, Number of Matches, and Distances](#71-data-number-of-matches-and-distances)
  - [7.2 Identifying the Candidates and Printing the Summary](#72-identifying-the-candidates-and-printing-the-summary)
  - [7.3 Four Plots](#73-four-plots)
- [Summary](#summary)
- [Self-Check Questions](#self-check-questions)

---

<br>

## 1. File Structure and How to Run

> **Try It First:** This document contains the complete code and line-by-line explanations. Solve the problems in the [assignment handout](Original/Assignment.md) yourself before reading on.

The five R scripts in `Solution/` correspond one to one to the problems, and the data are in the `data/` folder of the assignment.

| File | Problem | Input Data | Output | Run Time |
|:-----|:-----|:-----|:-----|-----:|
| [`Assignment3_Q1.R`](Solution/Assignment3_Q1.R) | Problem 1 | `Data1.tsv` | Data summary, LOOCV prediction per sample, confusion matrix, accuracy, sensitivity | About 20 s |
| [`Assignment3_Q2-1.R`](Solution/Assignment3_Q2-1.R) | Problem 2-1 | `Data2.tsv` | PCA, t-SNE, and UMAP plots | About 5 s |
| [`Assignment3_Q2-2.R`](Solution/Assignment3_Q2-2.R) | Problem 2-2 | `Data2.tsv` | Table of best accuracy per model, best model | About 2 min |
| [`Assignment3_Q2-3.R`](Solution/Assignment3_Q2-3.R) | Problem 2-3 | `Data2.tsv` | Table of best sensitivity per model, best model | About 2 min |
| [`Assignment3_Q3.R`](Solution/Assignment3_Q3.R) | Problem 3 | `Data3_DNA_Database.csv`, `Data3_DNA_Query.csv` | Summary statistics, first and second candidates, 4 plots | About 8 s |

*Table 1. Structure of the HW3 scripts*

The run times are approximate values with R 4.5.1. The scripts find the data folder relative to their own folder, so run them with `source()`. If R was opened at the repository root, run them as follows; in RStudio, open a script and press the Source button.

```r
source("Coursework/HW03_Supervised-Learning/Solution/Assignment3_Q1.R")
```

---

<br>

## 2. Parts Common to the Five Scripts

Lines 1-31 of `Assignment3_Q1.R` serve as the example.

```r
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
WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../data")
if (dir.exists(WORK_DIR)) {
  setwd(WORK_DIR)
} else {
  warning("작업 경로를 찾을 수 없습니다. 현재 작업 디렉토리를 사용합니다.")
}
```

- Lines 1-4 are a Doxygen-style header with the file name, a one-line description, the author, and the date.
- Each package is first loaded with `require()`, and installed if that fails. limma and pamr are treated as Bioconductor packages and installed with `BiocManager::install()`, and the others are installed from CRAN with `install.packages()`. The package names are passed as string variables, so `character.only = TRUE` is needed.
- The working directory is set in the same way as in HW2. When the script is run with `source()`, the `data/` folder next to it is built from the script path in `sys.frame(1)$ofile`, and `setwd()` moves there only if the folder exists.
- The other four scripts have the same structure and differ only in the package list. `Assignment3_Q3.R` calls `library()` only when installation was needed, but `require()` already loads installed packages, so the behavior is the same.

> **Caution:** This path setting works only when the script is run with `source()`. When it is run with `Rscript Assignment3_Q1.R`, the first frame has no `ofile` and the path is not found, so put the path of the data folder into `WORK_DIR` directly.

---

<br>

## 3. Assignment3_Q1.R: LOOCV Classification Pipeline

### 3.1 Labels and Feature Matrix

```r
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
```

- Giving `check.names = FALSE` to `read.delim()` keeps the column names as they are instead of fixing them to R's variable naming rules. The first column is the sample name `sampleName`.
- `grepl("Asthma", sample_id, ignore.case = TRUE)` returns a logical vector of whether each sample name contains `Asthma`, and `ifelse()` turns it into character labels. The `levels = c("Control", "Asthma")` of `factor()` makes Control the reference level.
- `data.matrix()` converts the data frame into a numeric matrix. Missing and infinite values found by `is.na()` and `!is.finite()` are replaced with 0, and the column numbers returned by `caret::nearZeroVar()` are removed by negative indexing. In these data 249 columns are removed, leaving 16,024.

### 3.2 Splitting the Training Set and the Validation Sample

```r
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
```

`run_pamr_loocv()` loops as many times as there are samples, and `setdiff(1:n, i)` makes the row numbers of the training set without the i-th sample. `drop = FALSE` keeps the result as a one-row matrix instead of a vector even when only one row is extracted, so that the later matrix operations work on the same shape. `set.seed(2025)` is called once before the loop and fixes the random numbers of SMOTE.

### 3.3 limma Feature Selection

```r
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
```

- `model.matrix(~ y_train_curr)` builds a design matrix of an intercept column and a column indicating Asthma.
- limma takes a matrix with genes as rows and samples as columns, so the data are transposed with `t()` before being passed to `lmFit()`. `lmFit()` fits a linear model to each gene, and `eBayes()` computes moderated t statistics and p-values by sharing the variance information of all genes.
- `topTable(coef = 2, number = 20, sort.by = "P")` picks 20 genes in increasing order of the p-value of the second coefficient (the difference between Asthma and Control). `adjust.method = "none"` applies no multiple testing correction, but the sort order is the same with or without correction.
- There is a branch that uses all features when the training set has only one class, since no test is possible then. In LOOCV the training set always has both classes, so this branch is never run.

### 3.4 SMOTE

```r
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
```

`smotefamily::SMOTE()` takes the feature data frame `X` and the labels `target` separately. `K = 1` makes each minority-class sample create synthetic samples between itself and its single nearest sample of the same class, and `dup_size = 0` makes the number to create be decided automatically from the size difference of the two classes. The `$data` of the result is a data frame combining the original and synthetic samples, and its last column is the label (`class`). Because `as.factor()` orders the levels of character labels alphabetically, the levels of `y_train_smote` are Asthma, Control, unlike `y` in Section 3.1. In these data, a training set with 3 Asthma becomes 15 to 17, and one with 2 Asthma becomes 18 to 18.

### 3.5 PAMR Training and Prediction

```r
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
```

- pamr takes as input a list holding `x` (a gene × sample matrix), `y` (labels), and `geneid`.
- By default, `pamr.train(threshold = NULL)` builds 30 thresholds from 0 up to the value at which all genes are shrunk to 0, and stores the shrunken class means at each threshold. The progress display printed during training is hidden with `capture.output()`. The argument of `capture.output()` is evaluated in the environment of the calling function, so `pam_fit` remains a variable inside the loop.
- `pam_fit$threshold[length(pam_fit$threshold)]` is the last value of the threshold vector, that is, the largest threshold. At this value 0 genes remain, and the prediction is decided only by the class prior probabilities. The result and its meaning are in [Section 3.4 of the HW3 assignment explanation](Assignment-Explanation.md#34-review-of-the-threshold-choice).
- `pamr.predict(type = "class")` returns the class of the validation sample as a factor, which `as.character()` converts and stores in `preds`.

### 3.6 Collecting and Printing the Results

```r
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
```

`result_df` holds the actual label, the predicted label, and whether they match for each sample, and `mean()` gives the proportion of `TRUE` in a logical vector, that is, the accuracy. `table(Truth = y, Pred = final_pred)` is the confusion matrix, and the sensitivity is the proportion predicted as Asthma in the actual Asthma row. Among the output of the following `cat()` and `print()` lines, the performance summary is as follows.

```text
- Confusion Matrix (LOOCV):
         Pred
Truth     Asthma Control
  Control      0      18
  Asthma       3       0

- LOOCV Total Accuracy: 100.00%
- Asthma Sensitivity: 100.00%
```

---

<br>

## 4. Assignment3_Q2-1.R: Three Two-Dimensional Visualizations

```r
## 2. 데이터 불러오기
data <- read.delim("Data2.tsv",
                   header = TRUE,
                   sep = "\t",
                   check.names = FALSE)


## 3. 라벨 / 피처 분리
data$Disease <- factor(data$Disease)  # "COVID19", "Healthy"

feature_cols <- setdiff(colnames(data), "Disease")
X <- as.matrix(data[, feature_cols])


## 4. 표준화
X_scaled <- scale(X)

## ------------------------------------------------
## (1) PCA 2D
## ------------------------------------------------
pca <- prcomp(X_scaled, center = FALSE, scale. = FALSE)
pca_var <- pca$sdev^2 / sum(pca$sdev^2)

pca_df <- data.frame(
  PC1 = pca$x[, 1],
  PC2 = pca$x[, 2],
  Disease = data$Disease
)
```

The `Disease` column is converted to a factor, a feature matrix is built from the remaining column names (`F1`-`F10`), and `scale()` standardizes it. PCA applies `prcomp()` to the standardized matrix and stores the first two principal component scores in a data frame.

```r
set.seed(2025)

tsne_out <- Rtsne(
  X_scaled,
  dims = 2,
  perplexity = 30,
  verbose = TRUE,
  max_iter = 1000,
  check_duplicates = FALSE
)
```

```r
set.seed(2025)

umap_config <- umap.defaults
umap_out <- umap(X_scaled, config = umap_config)
```

- The perplexity of `Rtsne()` is 30, the same as the default. With 999 samples, $3 \times 30 \le 998$ holds. `verbose = TRUE` prints the error at each iteration, and `max_iter = 1000` is the number of optimization iterations.
- `umap.defaults` is the default configuration object of the umap package (15 neighbors, minimum distance 0.1, and so on), passed as is as `config`.
- Each of the three results is drawn as a ggplot scatter plot, and `theme(plot.title = element_text(hjust = 0.5))` centers the title.

```r
## 하나의 플롯에서 legend 추출
legend_b <- cowplot::get_legend(
  p_pca + theme(legend.position = "right")
)

## 각 플롯에서는 legend 제거
p_pca_nl  <- p_pca  + theme(legend.position = "none")
p_tsne_nl <- p_tsne + theme(legend.position = "none")
p_umap_nl <- p_umap + theme(legend.position = "none")

## PCA / t-SNE / UMAP
plot_row <- cowplot::plot_grid(
  p_pca_nl,
  p_tsne_nl,
  p_umap_nl,
  nrow = 1,
  labels = c("A", "B", "C"),
  label_size = 12
)

final_plot <- cowplot::plot_grid(
  plot_row,
  legend_b,
  ncol = 2,
  rel_widths = c(3.5, 0.8)
)

print(final_plot)
```

cowplot's `get_legend()` extracts only the legend from one plot. After the legends of the three plots are removed, `plot_grid(nrow = 1, labels = c("A", "B", "C"))` places them in one row, and the outer `plot_grid(ncol = 2, rel_widths = c(3.5, 0.8))` places the row of plots and the legend side by side with widths of 3.5:0.8.

---

<br>

## 5. Assignment3_Q2-2.R: Model Comparison by Accuracy

### 5.1 Cross-Validation Setup

```r
## 3. 라벨 / 피처 준비
## Disease: Healthy / COVID19 (양성 클래스는 COVID19)
data$Disease <- factor(data$Disease,
                       levels = c("Healthy", "COVID19"))

feature_cols <- setdiff(colnames(data), "Disease")
df <- data[, c(feature_cols, "Disease")]

str(df)


## 4. 교차검증 설정 (Accuracy)
set.seed(2025)

ctrl_acc <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3,
  classProbs = TRUE,
  savePredictions = "final"
)
```

- `levels = c("Healthy", "COVID19")` sets the level order. The accuracy is the same regardless of the level order.
- `str(df)` prints the structure of 999 rows and 11 columns.
- `trainControl(method = "repeatedcv", number = 10, repeats = 3)` repeats 10-fold cross-validation 3 times with different splits and averages the 30 validation results. `classProbs = TRUE` also computes class probabilities, and `savePredictions = "final"` saves the validation predictions of the final parameters.

### 5.2 Model Training

```r
## 5-1. Logistic Regression
set.seed(2025)
fit_glm <- train(
  Disease ~ .,
  data = df,
  method = "glm",
  family = binomial,
  preProcess = c("center", "scale"),
  trControl = ctrl_acc,
  metric = "Accuracy"
)
model_list$Logistic <- fit_glm
```

All models are trained with `train()` calls of the same form. `Disease ~ .` is a formula using all the remaining columns as explanatory variables, `method` selects the model, and `preProcess = c("center", "scale")` standardizes with the mean and standard deviation computed from the training data of each validation iteration. Arguments unknown to `train()`, such as `family = binomial`, are passed to the internal model function (`glm()`). The `set.seed(2025)` before each call makes all models use the same cross-validation splits, which makes the comparison fair.

```r
## 5-4. k-NN (k-최근접이웃)
set.seed(2025)
fit_knn <- train(
  Disease ~ .,
  data = df,
  method = "knn",
  preProcess = c("center", "scale"),
  trControl = ctrl_acc,
  tuneGrid = data.frame(k = seq(3, 25, by = 2)),
  metric = "Accuracy"
)
model_list$kNN <- fit_knn

## 5-5. Naive Bayes
set.seed(2025)
fit_nb <- train(
  Disease ~ .,
  data = df,
  method = "nb",
  preProcess = c("center", "scale"),
  trControl = ctrl_acc,
  tuneLength = 5,          # usekernel, fL, adjust 등을 자동 튜닝
  metric = "Accuracy"
)
model_list$NaiveBayes <- fit_nb
```

Parameter candidates are given in two ways. `tuneGrid` gives the candidates directly as a data frame (k = 3, 5, ..., 25 for kNN), and `tuneLength` sets only the number of candidates, chosen by caret's rules. Naive Bayes (`method = "nb"`, klaR package) varies only the two values of `usekernel` (`FALSE`, `TRUE`) even with `tuneLength = 5`, holding `fL = 0` and `adjust = 1` fixed. Linear SVM uses `C = 2^seq(-5, 5, by = 1)`, and RBF SVM varies `C` over 10 values with `tuneLength = 10`, with `sigma` fixed at the value kernlab estimates from the data.

```r
## 5-8. Random Forest
set.seed(2025)
fit_rf <- train(
  Disease ~ .,
  data = df,
  method = "rf",
  trControl = ctrl_acc,
  tuneGrid = data.frame(mtry = 2:8),
  metric = "Accuracy"
)
model_list$RandomForest <- fit_rf

## 5-9. Gradient Boosting (GBM)
set.seed(2025)
fit_gbm <- train(
  Disease ~ .,
  data = df,
  method = "gbm",
  trControl = ctrl_acc,
  verbose = FALSE,
  tuneGrid = expand.grid(
    n.trees = c(100, 200, 300),
    interaction.depth = c(1, 3, 5),
    shrinkage = c(0.05, 0.1),
    n.minobsinnode = c(10, 20)
  ),
  metric = "Accuracy"
)
model_list$GBM <- fit_gbm
```

Random Forest varies `mtry` (the number of variables considered at each split) from 2 to 8, and GBM tries the 36 combinations of 3 numbers of trees, 3 depths, 2 learning rates, and 2 minimum leaf sizes made by `expand.grid()`. The two tree models are not affected by the scale of the variables, so they are not standardized. `verbose = FALSE` turns off GBM's training output. The trained models are collected by name in `model_list`.

### 5.3 Best Accuracy of Each Model

```r
## 6. 모델별 최고 Accuracy 정리
get_best_acc <- function(fit) {
  res <- fit$results
  idx <- which.max(res$Accuracy)
  return(res$Accuracy[idx])
}

best_acc <- sapply(model_list, get_best_acc)

result_table <- data.frame(
  Model = names(best_acc),
  BestAccuracy = as.numeric(best_acc)
)

## Accuracy 내림차순 정렬
result_table <- result_table[order(-result_table$BestAccuracy), ]

cat("\n=== 모델별 최고 CV Accuracy (내림차순 정렬) ===\n")
print(result_table, row.names = FALSE)


## 7. 가장 좋은 모델 객체 확인
best_model_name <- result_table$Model[1]
cat("\nAccuracy 기준 최적 모델:", best_model_name, "\n")

best_model <- model_list[[best_model_name]]
print(best_model)
```

`fit$results` is a data frame holding the mean cross-validated accuracy for each parameter candidate, and `which.max()` extracts the largest value. `sapply()` applies this to all models to make a named vector, and `order(-...)` sorts it in decreasing order. Several warnings are printed during the run, but the result is as follows.

```text
=== 모델별 최고 CV Accuracy (내림차순 정렬) ===
        Model BestAccuracy
   NaiveBayes    0.9305892
          QDA    0.9255758
          GBM    0.9212391
 RandomForest    0.9152290
      SVM_RBF    0.8812222
          kNN    0.8308114
   SVM_Linear    0.6026094
          LDA    0.6019495
     Logistic    0.6002828

Accuracy 기준 최적 모델: NaiveBayes 
```

The final `print(best_model)` prints the results of Naive Bayes for each parameter, and `FALSE` is chosen because the accuracy 0.9305892 and Kappa 0.8611905 with `usekernel = FALSE` are very slightly higher than the 0.9305859 with `usekernel = TRUE`.

---

<br>

## 6. Assignment3_Q2-3.R: Changes for the Sensitivity Criterion

`Assignment3_Q2-3.R` has the same structure as `Assignment3_Q2-2.R` and differs in only three places.

```r
## 3. 라벨 / 피처 준비
## 양성 클래스(positive)를 COVID19로 두기 위해 레벨 순서를 이렇게 설정
data$Disease <- factor(data$Disease,
                       levels = c("COVID19", "Healthy"))
```

```r
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
```

```r
## 6. 모델별 최고 Sensitivity 정리

get_best_sens <- function(fit) {
  res <- fit$results
  idx <- which.max(res$Sens)
  return(res$Sens[idx])
```

- COVID19 is made the first level and thus the positive class. `twoClassSummary` treats the first level as positive when computing the sensitivity.
- `summaryFunction = twoClassSummary` computes the area under the ROC curve (`ROC`), sensitivity (`Sens`), and specificity (`Spec`) instead of accuracy, and since it needs class probabilities, it is used together with `classProbs = TRUE`.
- In the nine `train()` calls, `metric = "Sens"` chooses the parameter with the highest sensitivity, and the summary function also extracts the maximum from `res$Sens`.

```text
=== 모델별 최고 CV Sensitivity (내림차순 정렬) ===
        Model BestSensitivity
          GBM       0.9106667
          QDA       0.9093333
   NaiveBayes       0.9086667
 RandomForest       0.8920000
      SVM_RBF       0.8600000
          kNN       0.7373333
          LDA       0.5846667
     Logistic       0.5840000
   SVM_Linear       0.5833333

Sensitivity 기준 최적 모델: GBM 
```

---

<br>

## 7. Assignment3_Q3.R: DNA Match Search

### 7.1 Data, Number of Matches, and Distances

```r
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
```

- `grep("^DNA_", colnames(db), value = TRUE)` returns the 1,000 column names starting with `DNA_`. `X_db` is a 2,178 × 1,000 matrix, and `x_q` is a numeric vector of length 1,000.
- `matrix(rep(x_q, each = n_db), nrow = n_db)` is a 2,178 × 1,000 matrix whose rows are all `x_q`. `rep(each = n_db)` repeats each element of `x_q` 2,178 times, and a matrix is filled column by column, so every entry of the j-th column is `x_q[j]`. Comparing this matrix with `X_db` by `==` gives a logical matrix of element-wise matches.
- `rowSums()` counts each `TRUE` as 1 to give the number of matches per individual, and the Hamming distance is 1,000 minus that value.
- `sweep(X_db, 2, x_q, FUN = "-")` subtracts `x_q` from each row (2 means a statistic along the columns), and the square root of the row sums of the squares is the Euclidean distance.

### 7.2 Identifying the Candidates and Printing the Summary

```r
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
```

`which.min()` returns the row number with the smallest Hamming distance. The second candidate is the second element of `order()` sorted by Hamming distance and, for ties, by Euclidean distance. After computing logical columns marking the two candidates and the means and standard deviations of the number of matches and the Hamming distance, the script prints the summary with `cat(sprintf(...))`.

```text
- Matches with Query:
  * Mean matches:  373.48
  * SD of matches: 19.42

- Best Match Candidate (Hamming distance 기준 1등):
  * Subject ID: Individual_1145
  * #Matched markers: 945 / 1000
  * #Mismatched markers (Hamming): 55
  * Euclidean distance: 10.1489

- Second Best Candidate (Hamming distance 기준 2등):
  * Subject ID: Individual_306
  * #Matched markers: 432 / 1000
  * #Mismatched markers (Hamming): 568
  * Euclidean distance: 30.3645
```

### 7.3 Four Plots

```r
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
```

dplyr's `arrange(Hamming)` sorts the rows in increasing order of Hamming distance, and `mutate(Rank = row_number())` assigns ranks in the sorted order. On top of all the points and the line, the rows of the first and second candidates alone are drawn again as large red and blue points, and ggrepel's `geom_text_repel()` adds labels that do not overlap the points.

```r
p_hist <- ggplot(score_df, aes(x = Hamming)) +
  geom_histogram(binwidth = max(1, floor(sd_hamming / 2)),
                 fill = "grey80", color = "black") +
  geom_vline(xintercept = score_df$Hamming[best_idx],
             color = "red", linewidth = 1.0) +
  geom_vline(xintercept = score_df$Hamming[second_idx],
             color = "blue", linetype = "dashed", linewidth = 1.0) +
```

The bin width of the histogram is half the standard deviation of the Hamming distance, rounded down, which is $\lfloor 19.42/2 \rfloor = 9$ for these data. `geom_vline()` draws vertical lines at the Hamming distances of the first candidate (solid, red) and the second candidate (dashed, blue), and the following `annotate("text", y = Inf, vjust = ...)` writes the candidate names at the top edge of the plot.

```r
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
```

The top 30 people are chosen in decreasing order of the number of matches. When `coord_flip()` lays the bars horizontally, the first factor level goes to the bottom, so `levels = rev(...)` reverses the order to put rank 1 at the top. `fill = Subject == best_subject` splits the colors by a logical value, and `scale_fill_manual()` fills `TRUE` in red and `FALSE` in gray.

```r
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
```

PCA is performed on the 2,179 × 1,000 matrix made by appending the query as the last row with `rbind(X_db, x_q)`. The row order is the same as the database, so row `best_idx` is the first candidate and row `n_db + 1` is the query, and only the `Group` of these two rows is changed to give them different colors and shapes.

---

<br>

## Summary

| Concept | Key Summary |
|:-----|:-----|
| LOOCV loop | `setdiff(1:n, i)` builds the training set, and feature selection, SMOTE, and training are all performed inside the loop. |
| limma | A gene × sample matrix is passed to `lmFit()` and `eBayes()`, and `topTable(coef = 2, number = 20, sort.by = "P")` picks the top genes. |
| PAMR threshold | The threshold vector of `pamr.train()` grows from 0, so its last value is the largest threshold, which shrinks all genes to 0. |
| caret comparison | The same `set.seed()` and `trainControl()` align the cross-validation splits of all models, and the best value of each metric is taken from `fit$results`. |
| Sensitivity criterion | The positive class is made the first level, and `twoClassSummary` and `metric = "Sens"` are used. |
| Comparing a vector with a matrix | `X == matrix(rep(x, each = n), nrow = n)` with `rowSums()` gives the numbers of matches, and `sweep()` gives the Euclidean distances, all at once. |

---

<br>

## Self-Check Questions

1. **drop = FALSE:** What problem can arise when one row is extracted without `drop = FALSE`, as in `X[test_idx, ]`?

   <details>
   <summary>Answer</summary>

   When only one row is extracted, R drops the dimension and returns a named vector. Then `t(X_test_sel)` becomes a 1 × gene matrix instead of a gene × 1 matrix, for example, so functions expecting a matrix get a mismatched shape and raise an error or compute wrongly. `drop = FALSE` keeps the shape of a one-row matrix.

   </details>

2. **First value of the threshold vector:** If the script had used `pam_fit$threshold[1]`, how many genes would be used for prediction?

   <details>
   <summary>Answer</summary>

   The first value is 0, so no gene is shrunk and all 20 genes chosen by limma are used. As the threshold grows, fewer genes remain, and at the last value none remain.

   </details>

3. **Role of the same seed:** How would the model comparison be affected without `set.seed(2025)` before each `train()` call?

   <details>
   <summary>Answer</summary>

   The cross-validation splits would differ from model to model. Then the differences in accuracy would mix the luck of the splits with the differences between models, and the ranking of models with similar performance (for example, Naive Bayes, QDA, and GBM at the top of the table) could change with the splits. The same seed makes all models be evaluated on the same splits.

   </details>

4. **The each argument of rep:** With `x_q = c(0, 2)` and `n_db = 3`, compare the results of `matrix(rep(x_q, each = 3), nrow = 3)` and `matrix(rep(x_q, 3), nrow = 3)`.

   <details>
   <summary>Answer</summary>

   `rep(x_q, each = 3)` is (0, 0, 0, 2, 2, 2), and filling it column by column gives a 3 × 2 matrix whose first column is all 0 and second column all 2, so every row equals `x_q`. `rep(x_q, 3)` is (0, 2, 0, 2, 0, 2), so the first column is (0, 2, 0) and the second (2, 0, 2), putting different values in each row and breaking the comparison.

   </details>
