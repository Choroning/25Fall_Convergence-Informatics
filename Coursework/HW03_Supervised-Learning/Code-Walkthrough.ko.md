# HW3 코드 총정리 — 지도 학습

[레포지토리 안내](../../README.ko.md) | [English](Code-Walkthrough.md) | [한국어](Code-Walkthrough.ko.md)

> **최종 수정일:** 2026-11-27

> **학습 목표:**
> 1. LOOCV 반복문 안에서 limma 특성 선택, SMOTE, PAMR 학습과 예측을 차례로 수행하는 코드를 읽고 각 단계의 입력과 출력을 설명할 수 있다
> 2. caret의 `trainControl()`과 `train()`으로 여러 모델을 같은 교차 검증 분할에서 학습하고, 결과 표에서 지표별 최고값을 뽑을 수 있다
> 3. 행렬의 원소별 비교와 `rowSums()`, `sweep()`으로 한 벡터와 데이터베이스 전체 사이의 일치 개수와 거리를 한 번에 계산할 수 있다
> 4. dplyr와 ggplot2, ggrepel, cowplot으로 순위 그림, 히스토그램, 막대그래프, 산점도를 만들고 특정 개체를 강조할 수 있다

---

## 목차

- [1. 파일 구성과 실행 방법](#1-파일-구성과-실행-방법)
- [2. 다섯 스크립트의 공통 부분](#2-다섯-스크립트의-공통-부분)
- [3. Assignment3_Q1.R: LOOCV 분류 파이프라인](#3-assignment3_q1r-loocv-분류-파이프라인)
  - [3.1 라벨과 특성 행렬](#31-라벨과-특성-행렬)
  - [3.2 훈련 세트와 검증 샘플의 분리](#32-훈련-세트와-검증-샘플의-분리)
  - [3.3 limma 특성 선택](#33-limma-특성-선택)
  - [3.4 SMOTE](#34-smote)
  - [3.5 PAMR 학습과 예측](#35-pamr-학습과-예측)
  - [3.6 결과 정리와 출력](#36-결과-정리와-출력)
- [4. Assignment3_Q2-1.R: 세 가지 2차원 시각화](#4-assignment3_q2-1r-세-가지-2차원-시각화)
- [5. Assignment3_Q2-2.R: 정확도 기준의 모델 비교](#5-assignment3_q2-2r-정확도-기준의-모델-비교)
  - [5.1 교차 검증 설정](#51-교차-검증-설정)
  - [5.2 모델 학습](#52-모델-학습)
  - [5.3 모델별 최고 정확도](#53-모델별-최고-정확도)
- [6. Assignment3_Q2-3.R: 민감도 기준으로 바꾼 부분](#6-assignment3_q2-3r-민감도-기준으로-바꾼-부분)
- [7. Assignment3_Q3.R: DNA 일치 검색](#7-assignment3_q3r-dna-일치-검색)
  - [7.1 데이터와 일치 개수, 거리](#71-데이터와-일치-개수-거리)
  - [7.2 후보 식별과 요약 출력](#72-후보-식별과-요약-출력)
  - [7.3 네 가지 그림](#73-네-가지-그림)
- [요약](#요약)
- [점검 문제](#점검-문제)

---

<br>

## 1. 파일 구성과 실행 방법

> **풀어 보기:** 이 문서는 작성한 코드 전체와 줄별 설명을 담고 있다. 먼저 [과제 안내문](Original/Assignment.ko.md)의 문제를 직접 풀어 본 뒤 읽는다.

`Solution/`의 R 스크립트 다섯 개는 문제마다 하나씩 대응하고, 데이터는 과제 폴더의 `data/`에 있다.

| 파일 | 문제 | 입력 데이터 | 출력 | 실행 시간 |
|:-----|:-----|:-----|:-----|-----:|
| [`Assignment3_Q1.R`](Solution/Assignment3_Q1.R) | 문제 1 | `Data1.tsv` | 데이터 요약, 샘플별 LOOCV 예측, 혼동 행렬, 정확도, 민감도 | 약 20초 |
| [`Assignment3_Q2-1.R`](Solution/Assignment3_Q2-1.R) | 문제 2-1 | `Data2.tsv` | PCA, t-SNE, UMAP 그림 | 약 5초 |
| [`Assignment3_Q2-2.R`](Solution/Assignment3_Q2-2.R) | 문제 2-2 | `Data2.tsv` | 모델별 최고 정확도 표, 최적 모델 | 약 2분 |
| [`Assignment3_Q2-3.R`](Solution/Assignment3_Q2-3.R) | 문제 2-3 | `Data2.tsv` | 모델별 최고 민감도 표, 최적 모델 | 약 2분 |
| [`Assignment3_Q3.R`](Solution/Assignment3_Q3.R) | 문제 3 | `Data3_DNA_Database.csv`, `Data3_DNA_Query.csv` | 요약 통계, 1위와 2위 후보, 그림 4개 | 약 8초 |

*표 1. HW3 스크립트의 구성*

실행 시간은 R 4.5.1 환경에서의 대략적인 값이다. 스크립트는 자신이 있는 폴더를 기준으로 데이터 폴더를 찾으므로 `source()`로 실행한다. 레포지토리 루트에서 R을 열었다면 다음과 같이 실행하고, RStudio에서는 스크립트를 연 뒤 Source 버튼을 누른다.

```r
source("Coursework/HW03_Supervised-Learning/Solution/Assignment3_Q1.R")
```

---

<br>

## 2. 다섯 스크립트의 공통 부분

`Assignment3_Q1.R`의 1\~31행을 예로 든다.

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

- 1\~4행은 파일 이름, 한 줄 설명, 작성자, 작성일을 적은 Doxygen 스타일 헤더이다.
- 패키지마다 `require()`로 불러오기를 시도하고, 실패하면 설치한다. limma와 pamr은 Bioconductor 패키지로 취급하여 `BiocManager::install()`로 설치하고, 나머지는 CRAN에서 `install.packages()`로 설치한다. 문자열 변수로 패키지 이름을 넘기므로 `character.only = TRUE`가 필요하다.
- 작업 경로는 HW2와 같은 방식으로 정한다. `source()`로 실행했을 때 `sys.frame(1)$ofile`에 든 스크립트 경로에서 옆의 `data/` 폴더를 만들고, 폴더가 있을 때만 `setwd()`로 옮긴다.
- 다른 네 스크립트도 같은 구조이며, 패키지 목록만 다르다. `Assignment3_Q3.R`은 설치에 실패한 경우에만 `library()`를 부르지만, 이미 설치된 패키지는 `require()`가 불러오므로 동작은 같다.

> **주의:** 이 경로 설정은 `source()`로 실행할 때만 동작한다. `Rscript Assignment3_Q1.R`로 실행하면 첫 프레임에 `ofile`이 없어 경로를 찾지 못하므로, `WORK_DIR`에 데이터 폴더의 경로를 직접 넣는다.

---

<br>

## 3. Assignment3_Q1.R: LOOCV 분류 파이프라인

### 3.1 라벨과 특성 행렬

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

- `read.delim()`에 `check.names = FALSE`를 주어 열 이름을 R의 변수 이름 규칙에 맞게 고치지 않고 그대로 둔다. 첫 열은 샘플 이름 `sampleName`이다.
- `grepl("Asthma", sample_id, ignore.case = TRUE)`는 샘플 이름에 `Asthma`가 들어 있는지를 논리 벡터로 돌려주고, `ifelse()`가 이를 문자 라벨로 바꾼다. `factor()`의 `levels = c("Control", "Asthma")`는 Control을 기준 수준으로 정한다.
- `data.matrix()`는 데이터 프레임을 수치 행렬로 바꾼다. `is.na()`와 `!is.finite()`로 찾은 결측값과 무한값을 0으로 바꾸고, `caret::nearZeroVar()`가 돌려준 열 번호를 음수 인덱스로 지운다. 이 데이터에서는 249개 열이 지워져 16,024개가 남는다.

### 3.2 훈련 세트와 검증 샘플의 분리

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

`run_pamr_loocv()`는 샘플 수만큼 반복하며, `setdiff(1:n, i)`로 i번째를 뺀 훈련 세트의 행 번호를 만든다. `drop = FALSE`는 한 행만 꺼내도 결과를 벡터가 아닌 1행 행렬로 유지하여, 이후의 행렬 연산이 같은 모양으로 동작하게 한다. `set.seed(2025)`는 반복문 앞에서 한 번 호출되어 SMOTE의 난수를 고정한다.

### 3.3 limma 특성 선택

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

- `model.matrix(~ y_train_curr)`는 절편 열과 Asthma 여부를 나타내는 열로 이루어진 설계 행렬을 만든다.
- limma는 행이 유전자, 열이 샘플인 행렬을 받으므로 `t()`로 전치하여 `lmFit()`에 넘긴다. `lmFit()`은 유전자마다 선형 모델을 적합하고, `eBayes()`는 모든 유전자의 분산 정보를 함께 써서 조정된 t 통계량과 유의확률을 계산한다.
- `topTable(coef = 2, number = 20, sort.by = "P")`는 두 번째 계수(Asthma와 Control의 차이)의 유의확률이 작은 순으로 유전자 20개를 고른다. `adjust.method = "none"`은 다중 검정 보정을 하지 않지만, 정렬 순서는 보정 여부와 상관없이 같다.
- 훈련 세트에 클래스가 하나뿐이면 검정을 할 수 없으므로 모든 특성을 쓰는 분기가 있다. LOOCV에서는 훈련 세트에 항상 두 클래스가 있으므로 이 분기는 실행되지 않는다.

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

`smotefamily::SMOTE()`는 특성 데이터 프레임 `X`와 라벨 `target`을 따로 받는다. `K = 1`은 소수 클래스의 각 샘플이 가장 가까운 같은 클래스 샘플 하나와의 사이에 합성 샘플을 만들게 하고, `dup_size = 0`은 만들 개수를 두 클래스의 크기 차이에서 자동으로 정하게 한다. 결과의 `$data`는 원래 샘플과 합성 샘플을 합친 데이터 프레임이고, 마지막 열이 라벨(`class`)이다. `as.factor()`는 문자 라벨의 수준을 알파벳순으로 정하므로, `y_train_smote`의 수준은 3.1절의 `y`와 달리 Asthma, Control 순서이다. 이 데이터에서 Asthma가 3명인 훈련 세트는 15 대 17, 2명인 훈련 세트는 18 대 18이 된다.

### 3.5 PAMR 학습과 예측

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

- pamr은 `x`(유전자 × 샘플 행렬), `y`(라벨), `geneid`를 담은 리스트를 입력으로 받는다.
- `pamr.train(threshold = NULL)`은 기본값에 따라 0부터 모든 유전자가 0으로 수축되는 값까지 임계값 30개를 만들고, 각 임계값에서의 수축된 클래스 평균을 저장한다. 학습 중 출력되는 진행 표시는 `capture.output()`으로 감춘다. `capture.output()`의 인자는 호출한 함수의 환경에서 평가되므로 `pam_fit`은 반복문 안의 변수로 남는다.
- `pam_fit$threshold[length(pam_fit$threshold)]`는 임계값 벡터의 마지막 값, 즉 가장 큰 임계값이다. 이 값에서는 남는 유전자가 0개가 되어 예측이 클래스 사전 확률로만 정해진다. 그 결과와 의미는 [HW3 과제 해설의 3.4절](Assignment-Explanation.ko.md#34-임계값-선택의-검토)에 있다.
- `pamr.predict(type = "class")`는 검증 샘플의 클래스를 팩터로 돌려주며, `as.character()`로 바꾸어 `preds`에 저장한다.

### 3.6 결과 정리와 출력

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

`result_df`는 샘플마다 실제 라벨, 예측 라벨, 일치 여부를 담고, `mean()`은 논리 벡터에서 `TRUE`의 비율, 즉 정확도를 준다. `table(Truth = y, Pred = final_pred)`는 혼동 행렬이며, 민감도는 실제 Asthma 행에서 Asthma로 예측한 비율이다. 이어지는 `cat()`과 `print()` 줄의 출력 가운데 성능 요약은 다음과 같다.

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

## 4. Assignment3_Q2-1.R: 세 가지 2차원 시각화

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

`Disease` 열을 팩터로 바꾸고, 나머지 열 이름(`F1`\~`F10`)으로 특성 행렬을 만든 뒤 `scale()`로 표준화한다. PCA는 표준화한 행렬에 `prcomp()`를 적용하고 처음 두 주성분 점수를 데이터 프레임에 담는다.

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

- `Rtsne()`의 perplexity는 기본값과 같은 30이다. 샘플이 999개이므로 $3 \times 30 \le 998$을 만족한다. `verbose = TRUE`는 반복마다 오차를 출력하고, `max_iter = 1000`은 최적화 반복 횟수이다.
- `umap.defaults`는 umap 패키지의 기본 설정 객체(이웃 수 15, 최소 거리 0.1 등)이며, 이를 그대로 `config`로 넘긴다.
- 세 결과는 각각 ggplot 산점도로 그리고, `theme(plot.title = element_text(hjust = 0.5))`로 제목을 가운데에 둔다.

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

cowplot의 `get_legend()`는 그림 하나에서 범례만 꺼낸다. 세 그림의 범례를 지운 뒤 `plot_grid(nrow = 1, labels = c("A", "B", "C"))`로 한 줄에 놓고, 바깥의 `plot_grid(ncol = 2, rel_widths = c(3.5, 0.8))`로 그림 줄과 범례를 3.5:0.8의 너비로 나란히 배치한다.

---

<br>

## 5. Assignment3_Q2-2.R: 정확도 기준의 모델 비교

### 5.1 교차 검증 설정

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

- `levels = c("Healthy", "COVID19")`로 수준 순서를 정한다. 정확도는 수준 순서와 상관없이 같다.
- `str(df)`는 999행 11열의 구조를 출력한다.
- `trainControl(method = "repeatedcv", number = 10, repeats = 3)`은 10-겹 교차 검증을 서로 다른 분할로 3번 반복하여 30개 검증 결과의 평균을 낸다. `classProbs = TRUE`는 클래스 확률도 계산하게 하고, `savePredictions = "final"`은 최종 매개변수의 검증 예측을 저장한다.

### 5.2 모델 학습

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

모든 모델은 같은 형식의 `train()` 호출로 학습한다. `Disease ~ .`는 나머지 모든 열을 설명변수로 쓰는 공식이고, `method`가 모델을 정하며, `preProcess = c("center", "scale")`은 각 검증 반복의 훈련 데이터로 평균과 표준편차를 구해 표준화한다. `family = binomial`처럼 `train()`이 모르는 인자는 내부의 모델 함수(`glm()`)로 전달된다. 각 호출 앞의 `set.seed(2025)`는 모든 모델이 같은 교차 검증 분할을 쓰게 하여 비교를 공정하게 한다.

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

매개변수 후보는 두 방식으로 준다. `tuneGrid`는 후보를 데이터 프레임으로 직접 주고(kNN의 k = 3, 5, ..., 25), `tuneLength`는 caret이 정한 규칙으로 후보 개수만 정한다. Naive Bayes(`method = "nb"`, klaR 패키지)는 `tuneLength = 5`라도 `usekernel`의 두 값(`FALSE`, `TRUE`)만 바꾸고 `fL = 0`, `adjust = 1`은 고정한다. 선형 SVM은 `C = 2^seq(-5, 5, by = 1)`, RBF SVM은 `tuneLength = 10`으로 `C`를 10개 바꾸며 `sigma`는 kernlab이 자료에서 추정한 값으로 고정한다.

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

Random Forest는 `mtry`(각 분할에서 고려하는 변수 수)를 2\~8로 바꾸고, GBM은 `expand.grid()`로 트리 수 3개, 깊이 3개, 학습률 2개, 잎 노드 최소 샘플 수 2개의 조합 36개를 시험한다. 두 트리 모델은 변수의 척도에 영향을 받지 않으므로 표준화하지 않는다. `verbose = FALSE`는 GBM의 학습 과정 출력을 끈다. 학습된 모델은 이름을 붙여 `model_list`에 모은다.

### 5.3 모델별 최고 정확도

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

`fit$results`는 매개변수 후보마다 교차 검증 정확도의 평균을 담은 데이터 프레임이고, `which.max()`로 가장 큰 값을 꺼낸다. `sapply()`가 모든 모델에 이를 적용하여 이름 붙은 벡터를 만들고, `order(-...)`로 내림차순 정렬한다. 실행 중 여러 경고가 출력되지만 결과는 다음과 같다.

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

마지막 `print(best_model)`은 Naive Bayes의 매개변수별 결과를 출력하며, `usekernel = FALSE`의 정확도 0.9305892와 Kappa 0.8611905가 `usekernel = TRUE`의 0.9305859보다 미세하게 높아 `FALSE`가 선택된다.

---

<br>

## 6. Assignment3_Q2-3.R: 민감도 기준으로 바꾼 부분

`Assignment3_Q2-3.R`은 `Assignment3_Q2-2.R`과 같은 구조이며 세 곳만 다르다.

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

- COVID19를 첫 번째 수준으로 두어 양성 클래스로 지정한다. `twoClassSummary`는 첫 번째 수준을 양성으로 보고 민감도를 계산한다.
- `summaryFunction = twoClassSummary`는 정확도 대신 ROC 곡선 아래 넓이(`ROC`), 민감도(`Sens`), 특이도(`Spec`)를 계산하며, 클래스 확률이 필요하므로 `classProbs = TRUE`와 함께 쓴다.
- 아홉 번의 `train()` 호출에서 `metric = "Sens"`로 민감도가 가장 높은 매개변수를 고르고, 정리 함수도 `res$Sens`에서 최댓값을 꺼낸다.

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

## 7. Assignment3_Q3.R: DNA 일치 검색

### 7.1 데이터와 일치 개수, 거리

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

- `grep("^DNA_", colnames(db), value = TRUE)`는 이름이 `DNA_`로 시작하는 열 이름 1,000개를 돌려준다. `X_db`는 2,178 × 1,000 행렬, `x_q`는 길이 1,000의 수치 벡터이다.
- `matrix(rep(x_q, each = n_db), nrow = n_db)`는 모든 행이 `x_q`인 2,178 × 1,000 행렬이다. `rep(each = n_db)`가 `x_q`의 각 원소를 2,178번씩 반복하고, 행렬은 열 방향으로 채워지므로 j번째 열이 모두 `x_q[j]`가 된다. 이 행렬과 `X_db`를 `==`로 비교하면 원소별 일치 여부를 담은 논리 행렬이 나온다.
- `rowSums()`는 논리값의 `TRUE`를 1로 세어 개인별 일치 개수를 주고, Hamming 거리는 1,000에서 그 값을 뺀 값이다.
- `sweep(X_db, 2, x_q, FUN = "-")`는 각 행에서 `x_q`를 빼고(2는 열 방향의 통계량을 쓴다는 뜻), 제곱의 행 합에 제곱근을 씌우면 Euclidean 거리이다.

### 7.2 후보 식별과 요약 출력

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

`which.min()`은 Hamming 거리가 가장 작은 행 번호를 돌려준다. 2위는 Hamming 거리, 동률이면 Euclidean 거리 순으로 정렬한 `order()`의 두 번째 원소이다. 두 후보를 표시하는 논리 열과 일치 개수, Hamming 거리의 평균과 표준편차를 계산한 뒤 `cat(sprintf(...))`로 요약을 출력한다.

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

### 7.3 네 가지 그림

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

dplyr의 `arrange(Hamming)`은 Hamming 거리의 오름차순으로 행을 정렬하고, `mutate(Rank = row_number())`는 정렬된 순서대로 순위를 붙인다. 전체 점과 선을 그린 위에 1위와 2위의 행만 골라 빨간색과 파란색의 큰 점을 덧그리고, ggrepel의 `geom_text_repel()`로 이름표가 점과 겹치지 않게 단다.

```r
p_hist <- ggplot(score_df, aes(x = Hamming)) +
  geom_histogram(binwidth = max(1, floor(sd_hamming / 2)),
                 fill = "grey80", color = "black") +
  geom_vline(xintercept = score_df$Hamming[best_idx],
             color = "red", linewidth = 1.0) +
  geom_vline(xintercept = score_df$Hamming[second_idx],
             color = "blue", linetype = "dashed", linewidth = 1.0) +
```

히스토그램의 구간 폭은 Hamming 거리 표준편차의 절반을 내림한 값이며, 이 데이터에서는 $\lfloor 19.42/2 \rfloor = 9$이다. `geom_vline()`은 1위(실선, 빨간색)와 2위(점선, 파란색)의 Hamming 거리에 세로선을 긋고, 이어지는 `annotate("text", y = Inf, vjust = ...)`가 그래프 위쪽 가장자리에 후보 이름을 적는다.

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

일치 개수의 내림차순으로 상위 30명을 고른다. `coord_flip()`으로 막대를 가로로 눕히면 팩터의 첫 수준이 아래에 놓이므로, `levels = rev(...)`로 순서를 뒤집어 1위가 맨 위에 오게 한다. `fill = Subject == best_subject`는 논리값으로 색을 나누고, `scale_fill_manual()`이 `TRUE`를 빨간색, `FALSE`를 회색으로 칠한다.

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

`rbind(X_db, x_q)`로 쿼리를 마지막 행에 붙인 2,179 × 1,000 행렬에 PCA를 수행한다. 행 순서가 데이터베이스와 같으므로 `best_idx`번째 행은 1위 후보, `n_db + 1`번째 행은 쿼리이며, 이 두 행의 `Group`만 바꾸어 색과 모양을 달리한다.

---

<br>

## 요약

| 개념 | 핵심 요약 |
|:-----|:-----|
| LOOCV 반복문 | `setdiff(1:n, i)`로 훈련 세트를 만들고, 특성 선택, SMOTE, 학습을 모두 반복문 안에서 수행한다. |
| limma | 유전자 × 샘플 행렬을 `lmFit()`과 `eBayes()`에 넘기고, `topTable(coef = 2, number = 20, sort.by = "P")`로 상위 유전자를 고른다. |
| PAMR 임계값 | `pamr.train()`의 임계값 벡터는 0부터 커지므로 마지막 값은 모든 유전자를 0으로 수축시키는 가장 큰 임계값이다. |
| caret 비교 | 같은 `set.seed()`와 `trainControl()`로 모든 모델의 교차 검증 분할을 맞추고, `fit$results`에서 지표별 최고값을 꺼낸다. |
| 민감도 기준 | 양성 클래스를 첫 수준으로 두고 `twoClassSummary`와 `metric = "Sens"`를 쓴다. |
| 벡터와 행렬의 비교 | `X == matrix(rep(x, each = n), nrow = n)`과 `rowSums()`로 일치 개수를, `sweep()`으로 Euclidean 거리를 한 번에 구한다. |

---

<br>

## 점검 문제

1. **drop = FALSE:** `X[test_idx, ]`처럼 `drop = FALSE` 없이 한 행을 꺼내면 어떤 문제가 생길 수 있는가?

   <details>
   <summary>정답</summary>

   R은 한 행만 꺼내면 차원을 줄여 이름 붙은 벡터를 돌려준다. 그러면 `t(X_test_sel)`이 유전자 × 1 행렬이 아니라 1 × 유전자 행렬이 되는 등, 행렬을 기대하는 함수에서 모양이 맞지 않아 오류가 나거나 잘못 계산된다. `drop = FALSE`는 1행 행렬의 모양을 유지한다.

   </details>

2. **임계값 벡터의 첫 값:** 스크립트가 `pam_fit$threshold[1]`을 썼다면 예측에 쓰이는 유전자는 몇 개인가?

   <details>
   <summary>정답</summary>

   첫 값은 0이므로 어떤 유전자도 수축되지 않아, limma로 고른 20개 유전자를 모두 쓴다. 임계값이 커질수록 남는 유전자가 줄고, 마지막 값에서는 0개가 된다.

   </details>

3. **같은 시드의 역할:** 각 `train()` 호출 앞에 `set.seed(2025)`를 두지 않으면 모델 비교에 어떤 영향이 있는가?

   <details>
   <summary>정답</summary>

   교차 검증의 분할이 모델마다 달라진다. 그러면 정확도의 차이에 모델의 차이뿐 아니라 분할의 운도 섞여, 비슷한 성능의 모델들(예: 표 상위의 Naive Bayes, QDA, GBM)의 순위가 분할에 따라 바뀔 수 있다. 같은 시드는 모든 모델을 같은 분할에서 평가하게 한다.

   </details>

4. **rep의 each 인자:** `x_q = c(0, 2)`이고 `n_db = 3`일 때 `matrix(rep(x_q, each = 3), nrow = 3)`과 `matrix(rep(x_q, 3), nrow = 3)`의 결과를 비교하라.

   <details>
   <summary>정답</summary>

   `rep(x_q, each = 3)`은 (0, 0, 0, 2, 2, 2)이고 열 방향으로 채우면 첫 열이 모두 0, 둘째 열이 모두 2인 3 × 2 행렬이 되어 모든 행이 `x_q`와 같다. `rep(x_q, 3)`은 (0, 2, 0, 2, 0, 2)이므로 첫 열이 (0, 2, 0), 둘째 열이 (2, 0, 2)가 되어 행마다 다른 값이 들어가 비교가 틀어진다.

   </details>
