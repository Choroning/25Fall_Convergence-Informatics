# HW2 코드 총정리 — 비지도 학습

[레포지토리 안내](../../README.ko.md) | [English](Code-Walkthrough.md) | [한국어](Code-Walkthrough.ko.md)

> **최종 수정일:** 2026-11-17

> **학습 목표:**
> 1. 패키지 목록을 반복문으로 설치하고 불러오며, 스크립트의 위치를 기준으로 데이터 폴더를 찾을 수 있다
> 2. `prcomp()`, `Rtsne()`, `umap()`의 결과에서 2차원 좌표를 꺼내 ggplot2로 그리고 여러 그림을 한 화면에 배치할 수 있다
> 3. `dist()`, `hclust()`와 factoextra의 `fviz_dend()`, `fviz_nbclust()`로 군집화 결과를 시각화할 수 있다
> 4. readxl로 엑셀 파일을 읽어 날짜를 경과일로 바꾸고, `lm()`, `summary()`, `predict()`로 회귀 모델을 적합하고 예측할 수 있다

---

## 목차

- [1. 파일 구성과 실행 방법](#1-파일-구성과-실행-방법)
- [2. 일곱 스크립트의 공통 부분](#2-일곱-스크립트의-공통-부분)
  - [2.1 헤더와 패키지 준비](#21-헤더와-패키지-준비)
  - [2.2 작업 경로 설정](#22-작업-경로-설정)
- [3. Assignment2_Q1.R: 차원 축소 시각화](#3-assignment2_q1r-차원-축소-시각화)
  - [3.1 범례 추출 함수](#31-범례-추출-함수)
  - [3.2 볼록 껍질을 칠한 산점도 함수](#32-볼록-껍질을-칠한-산점도-함수)
  - [3.3 데이터셋 하나를 분석하는 함수](#33-데이터셋-하나를-분석하는-함수)
  - [3.4 실행과 배치](#34-실행과-배치)
- [4. Assignment2_Q3.R: 덴드로그램](#4-assignment2_q3r-덴드로그램)
- [5. Assignment2_Q4.R: Silhouette 그림](#5-assignment2_q4r-silhouette-그림)
- [6. Assignment2_Q6.R: 회귀 모델 적합](#6-assignment2_q6r-회귀-모델-적합)
  - [6.1 데이터 준비](#61-데이터-준비)
  - [6.2 모델 적합과 결과 출력](#62-모델-적합과-결과-출력)
  - [6.3 신뢰 구간을 포함한 시각화](#63-신뢰-구간을-포함한-시각화)
- [7. Assignment2_Q7.R, Assignment2_Q9.R: 날짜를 지정한 예측](#7-assignment2_q7r-assignment2_q9r-날짜를-지정한-예측)
- [8. Assignment2_Q8.R: 색을 지정한 산점도](#8-assignment2_q8r-색을-지정한-산점도)
- [요약](#요약)
- [점검 문제](#점검-문제)

---

<br>

## 1. 파일 구성과 실행 방법

> **풀어 보기:** 이 문서는 작성한 코드 전체와 줄별 설명을 담고 있다. 먼저 [과제 안내문](Original/Assignment.ko.md)의 문제를 직접 풀어 본 뒤 읽는다.

`Solution/`의 R 스크립트 일곱 개는 문제마다 하나씩 대응하고, 데이터는 과제 폴더의 `data/`에 있다.

| 파일 | 문제 | 입력 데이터 | 출력 |
|:-----|:-----|:-----|:-----|
| [`Assignment2_Q1.R`](Solution/Assignment2_Q1.R) | 문제 1 | `1.Homework2_OriginalData.tsv`, `2.Homework2_FilteredData.tsv` | 그림 6개를 배치한 한 장의 그림 |
| [`Assignment2_Q3.R`](Solution/Assignment2_Q3.R) | 문제 3 | `2.Homework2_FilteredData.tsv` | 가로형 덴드로그램 |
| [`Assignment2_Q4.R`](Solution/Assignment2_Q4.R) | 문제 4 | `2.Homework2_FilteredData.tsv` | Silhouette 그림 |
| [`Assignment2_Q6.R`](Solution/Assignment2_Q6.R) | 문제 6 | `HW2_Data3.xlsx` | 회귀 계수 표, $R^2$, 비교 문장, 신뢰 구간을 포함한 그림 |
| [`Assignment2_Q7.R`](Solution/Assignment2_Q7.R) | 문제 7 | `HW2_Data3.xlsx` | 2021-11-22의 예측 체중 |
| [`Assignment2_Q8.R`](Solution/Assignment2_Q8.R) | 문제 8 | `HW2_Data3.xlsx` | 산점도와 회귀 직선 |
| [`Assignment2_Q9.R`](Solution/Assignment2_Q9.R) | 문제 9 | `HW2_Data3.xlsx` | 2022-11-23의 예측 체중 |

*표 1. HW2 스크립트의 구성*

스크립트는 자신이 있는 폴더를 기준으로 데이터 폴더를 찾으므로 `source()`로 실행한다. 레포지토리 루트에서 R을 열었다면 다음과 같이 실행하고, RStudio에서는 스크립트를 연 뒤 Source 버튼을 누른다.

```r
source("Coursework/HW02_Unsupervised-Learning/Solution/Assignment2_Q1.R")
```

---

<br>

## 2. 일곱 스크립트의 공통 부분

### 2.1 헤더와 패키지 준비

`Assignment2_Q1.R`의 1\~12행을 예로 든다.

```r
# @file    Assignment2_Q1.R
# @brief   Dimensionality reduction comparison (PCA, t-SNE, UMAP) on original and filtered gene expression data with convex hull visualization
# @author  Cheolwon Park
# @date    2025-12-01

# 1. 라이브러리 로드
setRepositories(ind = 1:7)
pkg_list <- c("ggplot2", "gridExtra", "grid", "Rtsne", "umap", "stringr")
for (p in pkg_list) {
  if (!require(p, character.only = TRUE)) install.packages(p)
  library(p, character.only = TRUE)
}
```

- 1\~4행은 파일 이름, 한 줄 설명, 작성자, 작성일을 적은 Doxygen 스타일 헤더이다.
- `setRepositories(ind = 1:7)`은 `install.packages()`가 패키지를 찾을 저장소를 CRAN, Bioconductor 저장소들, R-Forge 등 일곱 곳으로 넓힌다.
- 패키지 이름을 문자열 벡터 `pkg_list`에 모으고 `for` 문으로 하나씩 처리한다. `require()`와 `library()`는 보통 따옴표 없는 이름을 받으므로, 변수 `p`에 든 문자열을 패키지 이름으로 쓰려면 `character.only = TRUE`를 주어야 한다. `require()`가 `FALSE`를 돌려주면(설치되어 있지 않으면) 설치한 뒤 불러온다.
- `Assignment2_Q3.R`과 `Assignment2_Q4.R`은 같은 반복문을 쓰고, 체중 데이터를 다루는 네 스크립트는 `if (!require("readxl")) install.packages("readxl")`처럼 패키지마다 한 줄씩 쓴다.

### 2.2 작업 경로 설정

```r
# 2. 작업 경로 설정
WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../data")
if(dir.exists(WORK_DIR)) setwd(WORK_DIR) else warning("경로를 확인하세요.")
```

- `source()`로 스크립트를 실행하면 호출 스택의 첫 프레임이 `source()`의 실행 환경이고, 그 안의 변수 `ofile`에 스크립트 경로가 들어 있다. `sys.frame(1)$ofile`은 이 경로를 꺼낸다.
- `dirname()`은 경로에서 파일 이름을 뗀 폴더(`.../Solution`)를 돌려주고, `file.path(..., "../data")`는 그 옆의 `data/` 경로를 만든다. `%||%`는 R 4.4.0부터 기본으로 제공되는 연산자로, 왼쪽 값이 `NULL`이면 오른쪽 값을 돌려준다.
- `dir.exists()`로 폴더가 있는지 확인한 뒤에만 `setwd()`로 작업 디렉토리를 바꾸고, 없으면 경고만 낸다. 이후의 파일 이름은 이 폴더를 기준으로 해석된다. `Assignment2_Q7.R`은 확인 없이 `setwd(WORK_DIR)`만 쓰므로 폴더가 없으면 오류로 멈춘다.

> **주의:** 이 방식은 `source()`로 실행할 때만 동작한다. `Rscript Assignment2_Q1.R`로 실행하거나 다른 함수 안에서 `source()`를 부르면 첫 프레임에 `ofile`이 없어 경로를 찾지 못한다. 그때는 `WORK_DIR`에 데이터 폴더의 경로를 직접 넣는다.

---

<br>

## 3. Assignment2_Q1.R: 차원 축소 시각화

### 3.1 범례 추출 함수

```r
get_legend <- function(myggplot){
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  if(length(leg) > 0) return(tmp$grobs[[leg]]) else return(NULL)
}
```

여섯 그림이 같은 범례를 공유하게 하려면 그림 하나에서 범례만 떼어 내야 한다. `ggplot_build()`는 ggplot 객체를 그릴 수 있는 데이터로 계산하고, `ggplot_gtable()`은 그것을 grid의 그래픽 객체(grob) 표로 바꾼다. 그 구성 요소(`tmp$grobs`) 가운데 이름이 `"guide-box"`인 것이 범례이므로, 그 위치를 찾아 돌려준다.

### 3.2 볼록 껍질을 칠한 산점도 함수

```r
create_plot <- function(df, x_col, y_col, group_col, title_txt, x_lab, y_lab) {

  # Convex Hull 좌표 계산
  hull_data <- do.call(rbind, lapply(split(df, df[[group_col]]), function(d) {
    d[chull(d[[x_col]], d[[y_col]]), ]
  }))

  ggplot(df, aes_string(x = x_col, y = y_col, color = group_col, fill = group_col)) +
    geom_polygon(data = hull_data, alpha = 0.2, show.legend = FALSE) +
    geom_point(size = 1.2, alpha = 0.8) +
    labs(title = title_txt, x = x_lab, y = y_lab) +
    theme_bw() +
    theme(legend.position = "bottom", # 추출용 (나중에 숨김)
          legend.title = element_blank(),
          plot.title = element_text(size = 11, face = "bold"))
}
```

- `split(df, df[[group_col]])`은 데이터 프레임을 질병별로 나눈 리스트를 만들고, `lapply()`는 각 조각에 함수를 적용한다.
- `chull(x, y)`는 평면 점들의 볼록 껍질을 이루는 점의 행 번호를 둘레 순서대로 돌려준다. 그 행만 남기면 다각형의 꼭짓점이 되고, `do.call(rbind, ...)`가 질병별 결과를 한 데이터 프레임으로 합친다.
- `aes_string()`은 열 이름을 문자열로 받아 미적 대응을 만든다. 함수 인자로 열 이름을 넘기기 위해 쓴 것이며, ggplot2 3.0.0부터는 사용 중단 예정(deprecated) 경고가 나온다. 같은 일을 `aes(x = .data[[x_col]], y = .data[[y_col]], ...)`로도 할 수 있다.
- `geom_polygon()`은 볼록 껍질을 투명도 0.2로 칠하고, 그 위에 `geom_point()`가 점을 찍는다. 범례는 `get_legend()`로 추출하기 위해 아래쪽에 두고, 나중에 각 그림에서 숨긴다.

### 3.3 데이터셋 하나를 분석하는 함수

```r
analyze_dataset <- function(file_name, label_prefix) {

  if(!file.exists(file_name)) return(NULL)

  # 데이터 로드
  raw_df <- read.delim(file_name, header = TRUE, row.names = 1)

  # 스케일링 수행
  mx_scaled <- scale(raw_df)

  # 중복 제거 (t-SNE 오류 방지)
  unique_idx <- !duplicated(mx_scaled)
  mx_scaled <- mx_scaled[unique_idx, ]

  # 라벨 파싱
  y_labels <- stringr::str_remove(rownames(mx_scaled), "[_0-9]+$")
```

- `read.delim()`은 탭 구분 파일을 읽고, `row.names = 1`은 첫 열 `sampleName`을 행 이름으로 쓴다. 결과는 21행(샘플) × 특징 수 열의 데이터 프레임이다.
- `scale()`은 열마다 평균을 빼고 표준편차로 나눈 행렬을 돌려준다. 행이 샘플이므로 각 유전자가 표준화된다.
- `Rtsne()`는 똑같은 행이 있으면 오류를 내므로 `duplicated()`로 중복 행을 찾아 지운다. 이 데이터에는 중복 행이 없어 21행이 그대로 남는다.
- `str_remove(문자열, 패턴)`은 정규식에 맞는 부분을 지운다. `"[_0-9]+$"`는 끝에 붙은 밑줄과 숫자의 연속이므로 `COVID19_Patient1`은 `COVID19_Patient`가 된다. 끝의 `Patient1`에서 숫자 `1`만 지워지고, `Patient`는 글자여서 남는다.

```r
  # 1) PCA
  fit_pca <- prcomp(mx_scaled, center = FALSE, scale. = FALSE)
  pca_var <- round(fit_pca$sdev^2 / sum(fit_pca$sdev^2) * 100, 1)
  df_pca <- data.frame(X = fit_pca$x[,1], Y = fit_pca$x[,2], Group = y_labels)

  p1 <- create_plot(df_pca, "X", "Y", "Group",
                    paste0("PCA (", label_prefix, ")"),
                    paste0("PC1 (", pca_var[1], "%)"),
                    paste0("PC2 (", pca_var[2], "%)"))
```

- 데이터가 이미 표준화되어 있으므로 `prcomp()`의 중심화와 척도 조정을 끈다.
- `fit_pca$sdev`는 각 주성분의 표준편차이므로 제곱하면 분산(고윳값)이다. 이를 전체 합으로 나누고 100을 곱해 소수점 한 자리로 반올림한 값이 설명 분산 비율(%)이다.
- `fit_pca$x`는 각 샘플의 주성분 점수 행렬이며, 첫 두 열을 x, y 좌표로 쓴다.

```r
  # 2) t-SNE
  set.seed(2025)
  perp_n <- floor((nrow(mx_scaled) - 1) / 3)
  fit_tsne <- Rtsne(mx_scaled, dims = 2, perplexity = perp_n, check_duplicates = FALSE)
  df_tsne <- data.frame(X = fit_tsne$Y[,1], Y = fit_tsne$Y[,2], Group = y_labels)

  p2 <- create_plot(df_tsne, "X", "Y", "Group",
                    paste0("t-SNE (", label_prefix, ")"), "t-SNE 1", "t-SNE 2")
```

- `Rtsne()`는 `nrow - 1 < 3 * perplexity`이면 오류를 내므로, perplexity를 허용되는 최댓값 $\lfloor (21 - 1)/3 \rfloor = 6$으로 둔다.
- 중복 행은 이미 지웠으므로 `check_duplicates = FALSE`로 검사를 생략한다.
- `Rtsne()`는 기본값 `pca = TRUE`, `initial_dims = 50`에 따라 먼저 PCA로 차원을 줄인 뒤 t-SNE를 수행한다. 샘플이 21개이면 주성분이 최대 21개이므로 사실상 모든 주성분을 쓴다.
- 결과의 `$Y`가 2차원 임베딩 좌표이다.

```r
  # 3) UMAP
  set.seed(2025)
  fit_umap <- umap(mx_scaled, n_neighbors = 15)
  df_umap <- data.frame(X = fit_umap$layout[,1], Y = fit_umap$layout[,2], Group = y_labels)

  p3 <- create_plot(df_umap, "X", "Y", "Group",
                    paste0("UMAP (", label_prefix, ")"), "UMAP 1", "UMAP 2")

  return(list(p1, p2, p3))
}
```

umap 패키지의 `umap()`은 설정을 인자로 바꿀 수 있으며, 여기서는 이웃 수를 기본값과 같은 15로 명시한다. 결과의 `$layout`이 임베딩 좌표이다. 함수는 세 그림을 리스트로 돌려준다.

### 3.4 실행과 배치

```r
# 파일명 정의
file_orig <- "1.Homework2_OriginalData.tsv"
file_filt <- "2.Homework2_FilteredData.tsv"

# 분석 실행
plots_orig <- analyze_dataset(file_orig, "Original")
plots_filt <- analyze_dataset(file_filt, "Filtered")

if(!is.null(plots_orig) & !is.null(plots_filt)) {

  # 범례 추출 (Original PCA 그래프에서 하나 가져옴)
  shared_leg <- get_legend(plots_orig[[1]])

  # 모든 개별 그래프에서 범례 숨기기
  pl_list <- c(plots_orig, plots_filt)
  pl_list_noleg <- lapply(pl_list, function(p) p + theme(legend.position = "none"))

  # 그리드 배치 (2행 3열)
  # 상단: Original Data (PCA, t-SNE, UMAP)
  # 하단: Filtered Data (PCA, t-SNE, UMAP)
  # 최하단: 공통 범례

  grid.arrange(arrangeGrob(grobs = pl_list_noleg, nrow = 2, ncol = 3),
               shared_leg,
               nrow = 2,
               heights = c(9, 1), # 그래프 영역 9 : 범례 영역 1 비율
               top = textGrob("Dimension Reduction Result",
                              gp = gpar(fontsize = 14, fontface = "bold")))

} else {
  stop("데이터 파일 중 하나를 찾을 수 없습니다.")
}
```

- 두 데이터에 같은 함수를 적용하고, 원본 데이터의 PCA 그림에서 범례를 하나 추출한다.
- `c()`로 두 리스트를 이어 그림 6개의 리스트를 만들고, 각 그림에 `theme(legend.position = "none")`을 더해 범례를 숨긴다.
- gridExtra의 `arrangeGrob()`은 그림 6개를 2행 3열로 묶은 객체를 만들고, 바깥의 `grid.arrange()`는 이 묶음과 범례를 세로로 9:1의 높이 비율로 쌓은 뒤 위쪽에 굵은 제목을 단다.
- 파일을 하나라도 찾지 못하면 `analyze_dataset()`이 `NULL`을 돌려주므로 `stop()`으로 멈춘다. `&`는 원소별 논리곱이지만 길이 1의 논리값끼리는 `&&`와 같은 결과를 준다.

---

<br>

## 4. Assignment2_Q3.R: 덴드로그램

```r
  raw_dataset <- read.delim(target_file, header = TRUE, row.names = 1)

  # [Standardization] 데이터 표준화 (Z-score)
  z_score_matrix <- scale(raw_dataset)

  # 4. 계층적 군집 분석 (Hierarchical Clustering)
  # Distance: Euclidean, Linkage: Ward.D2
  dist_metric <- dist(z_score_matrix, method = "euclidean")
  hierarchical_model <- hclust(dist_metric, method = "ward.D2")
```

- 필터링 데이터를 읽어 표준화한다. `if(file.exists(target_file))`로 파일이 있을 때만 실행하고, 없으면 `stop()`으로 멈춘다.
- `dist()`는 행(샘플) 사이의 거리를 계산하여 21 × 21 거리 행렬의 아래 삼각 부분을 담은 `dist` 객체를 돌려준다.
- `hclust()`는 병합적 계층 군집화를 수행한다. `"ward.D2"`는 거리를 제곱하여 Ward의 최소 분산 기준으로 병합한다.

```r
  viz_tree <- fviz_dend(hierarchical_model, k = 4,
                        horiz = TRUE,              # [핵심] 가로형 배치
                        cex = 0.7,                 # 폰트 크기
                        k_colors = "jco",          # JCO 출판용 색상
                        color_labels_by_k = TRUE,  # 그룹별 라벨 색상
                        rect = TRUE,               # 그룹 박스 표시
                        rect_border = "jco",
                        rect_fill = TRUE,
                        main = "Hierarchical Clustering Dendrogram (Ward's Method)",
                        xlab = "Samples", ylab = "Height (Euclidean Distance)") +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0.5), # 제목: 볼드, 중앙 정렬
      plot.margin = margin(t = 10, r = 10, b = 10, l = 10) # 가로형이므로 기본 여백만 있어도 충분
    )

  print(viz_tree)
```

factoextra의 `fviz_dend()`는 `hclust` 결과를 ggplot2 덴드로그램으로 그린다. `k = 4`는 트리를 4개 군집으로 자르고(`cutree()`와 같은 기준), `k_colors = "jco"`는 Journal of Clinical Oncology 팔레트로 군집마다 색을 칠한다. `rect = TRUE`, `rect_fill = TRUE`는 각 군집을 반투명한 상자로 감싸고, `horiz = TRUE`는 트리를 가로로 눕혀 긴 샘플 이름이 잘리지 않게 한다. 반환값이 ggplot 객체이므로 `theme()`을 더해 제목을 가운데로 맞출 수 있고, `print()`로 화면에 그린다. 가로형에서는 `xlab`이 세로축, `ylab`이 가로축(높이)의 이름이 된다.

---

<br>

## 5. Assignment2_Q4.R: Silhouette 그림

```r
  # [Standardization] 스케일링 수행 (필수 과정)
  # K-means는 거리 기반 알고리즘이므로 변수 간 스케일을 맞춰야 함
  std_data <- scale(raw_df)

  # -------------------------------------------------------
  # 4. 실루엣 스코어 플롯 그리기 (k = 2 ~ 10)
  # -------------------------------------------------------
  # fviz_nbclust 함수: 최적의 군집 수를 찾기 위한 시각화 도구
  # - method = "silhouette": 실루엣 계수 사용
  # - k.max = 10: 2부터 10까지 탐색

  viz_silhouette <- fviz_nbclust(std_data, kmeans, method = "silhouette", k.max = 10) +
    labs(title = "Q4. Silhouette Score for K-means Clustering",
         subtitle = "Optimal number of clusters (k) search range: 2-10",
         x = "Number of clusters k",
         y = "Average Silhouette Width") +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.title = element_text(face = "bold")
    )

  # 5. 결과 출력
  print(viz_silhouette)
```

- `fviz_nbclust(데이터, 군집 함수, method = "silhouette", k.max = 10)`은 K = 2, ..., 10마다 `kmeans()`를 실행하고, cluster 패키지의 `silhouette()`로 평균 Silhouette 폭을 계산하여 선 그래프로 그린다. 가장 큰 K에는 세로 점선을 긋고, K = 1은 0으로 표시한다. 함수 안에서 `set.seed(123)`을 먼저 호출하므로 `kmeans()`의 무작위 초기화가 실행마다 같다.
- 두 번째 인자에 함수 이름 `kmeans`를 그대로 넘긴다. R에서 함수는 값이므로 다른 함수의 인자가 될 수 있다.
- 결과가 ggplot 객체이므로 `labs()`로 제목과 축 이름을 바꾸고 `theme_minimal()`을 적용한다. 계산된 값은 `viz_silhouette$data`에 들어 있다.
- 스크립트 끝의 `cat()` 두 줄은 그림이 만들어졌다는 안내를 출력한다.

---

<br>

## 6. Assignment2_Q6.R: 회귀 모델 적합

### 6.1 데이터 준비

```r
  # 엑셀 파일 읽기 (첫 번째 시트 로드)
  data_df <- read_excel(filename, sheet = 1)

  # 데이터 전처리
  # 필요한 컬럼만 선택 (Date, ProfWeight_Kg, StudentWeight_Kg)
  # 엑셀에서 읽어올 때 컬럼명이 정확한지 확인 필요
  df_model <- data_df[, c("Date", "ProfWeight_Kg", "StudentWeight_Kg")]

  # 결측치 제거
  df_model <- na.omit(df_model)

  # 날짜 형식 변환 및 경과일(Days) 계산
  # readxl은 날짜를 POSIXct로 읽어오므로 Date로 변환
  df_model$Date <- as.Date(df_model$Date)
  start_date <- min(df_model$Date)
  df_model$Days <- as.numeric(df_model$Date - start_date)
```

- readxl의 `read_excel()`은 첫 번째 시트를 tibble로 읽는다. 시트의 오른쪽에 이름 없는 빈 열이 있어 `New names: ... -> ...8` 같은 메시지가 나오지만, 필요한 세 열만 고르므로 결과에는 영향이 없다.
- `na.omit()`은 결측값이 있는 행을 지운다. 이 데이터의 65행에는 세 열의 결측값이 없다.
- `read_excel()`은 날짜를 시각까지 담은 `POSIXct`로 읽으므로 `as.Date()`로 날짜만 남긴다. 두 `Date`의 차는 `difftime` 객체이고, `as.numeric()`으로 날수(0\~64)를 얻는다.

### 6.2 모델 적합과 결과 출력

```r
  # 4. 예측 모델링 (Simple Linear Regression)

  # (1) Professor Model
  model_prof <- lm(ProfWeight_Kg ~ Days, data = df_model)
  summary_prof <- summary(model_prof)

  # (2) Student Model
  model_stud <- lm(StudentWeight_Kg ~ Days, data = df_model)
  summary_stud <- summary(model_stud)

  # 결과 출력
  cat("==================================================\n")
  cat("[Established Model for Professor]\n")
  # 계수(Intercept, Slope) 출력
  print(coef(summary_prof))
  cat("R-squared:", summary_prof$r.squared, "\n\n")
```

- `lm(y ~ x, data)`는 최소제곱법으로 단순 선형 회귀를 적합한다. 공식의 `~` 왼쪽이 반응변수, 오른쪽이 설명변수이다.
- `summary()`는 계수의 추정값, 표준오차, t 값, 유의확률과 결정계수 등을 계산한다. `coef(summary_prof)`는 계수 표를 행렬로 꺼내고, `$r.squared`는 $R^2$이다. 학생 모델도 같은 방식으로 출력한다.

```text
==================================================
[Established Model for Professor]
               Estimate  Std. Error  t value      Pr(>|t|)
(Intercept) 89.74923077 0.188544789 476.0101 9.687429e-114
Days        -0.09394231 0.005082827 -18.4823  3.927806e-27
R-squared: 0.8442888 

[Established Model for Student]
              Estimate  Std. Error   t value      Pr(>|t|)
(Intercept) 82.0794406 0.152198286 539.29280 3.731684e-117
Days        -0.1545258 0.004102991 -37.66174  6.496385e-45
R-squared: 0.9574729 
==================================================
```

```r
  slope_prof <- coef(model_prof)[2]
  slope_stud <- coef(model_stud)[2]

  cat("[Comparison Result]\n")
  if(slope_stud < slope_prof) {
    cat("Student's slope (", round(slope_stud, 4), ") is steeper (more negative) than Professor's (", round(slope_prof, 4), ").\n")
    cat("Conclusion: The Student had a faster weight loss effect.\n")
  } else {
    cat("Professor's slope is steeper than Student's.\n")
    cat("Conclusion: The Professor had a faster weight loss effect.\n")
  }
```

`coef(model)`은 (절편, 기울기) 벡터이므로 `[2]`가 기울기이다. 두 기울기가 모두 음수이므로 더 작은(더 음수인) 쪽이 더 가파르게 감량한 것이고, `if` 문이 그 결과에 맞는 문장을 출력한다. 이 데이터에서는 다음이 출력된다.

```text
[Comparison Result]
Student's slope ( -0.1545 ) is steeper (more negative) than Professor's ( -0.0939 ).
Conclusion: The Student had a faster weight loss effect.
```

### 6.3 신뢰 구간을 포함한 시각화

```r
  df_plot <- rbind(
    data.frame(Days = df_model$Days, Weight = df_model$ProfWeight_Kg, Person = "Professor"),
    data.frame(Days = df_model$Days, Weight = df_model$StudentWeight_Kg, Person = "Student")
  )

  p <- ggplot(df_plot, aes(x = Days, y = Weight, color = Person)) +
    geom_point(alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", se = TRUE, aes(fill = Person), alpha = 0.15) +
    labs(title = "Weight Loss Prediction Model (Summer 2021)",
         subtitle = paste("Prof Slope:", round(slope_prof, 3),
                          "vs Student Slope:", round(slope_stud, 3)),
         x = "Days Elapsed (since start date)",
         y = "Weight (kg)") +
    theme_bw() +
    theme(legend.position = "bottom")

  print(p)
```

- 한 행에 두 사람의 체중이 함께 있는 넓은 형식(wide format)을, 한 행에 한 사람의 체중 하나가 있는 긴 형식(long format)으로 바꾼다. 두 데이터 프레임을 `rbind()`로 쌓고 `Person` 열로 대상을 구분하므로 tidyr 패키지가 필요 없다.
- `geom_smooth(method = "lm", se = TRUE)`는 색 그룹마다 따로 회귀 직선을 적합하여 그리고, 직선의 95% 신뢰 구간을 띠로 칠한다. 이 직선은 `lm()`으로 적합한 모델과 같다.
- 부제목에는 두 기울기를 소수점 세 자리로 넣는다.

---

<br>

## 7. Assignment2_Q7.R, Assignment2_Q9.R: 날짜를 지정한 예측

두 스크립트는 문제 6과 같은 방식으로 데이터를 준비하고 두 모델을 다시 적합한 뒤, 목표 날짜만 바꾸어 예측한다. `Assignment2_Q7.R`의 28\~37행은 다음과 같다.

```r
  # 4. 2021-11-22 시점 예측
  target_date <- as.Date("2021-11-22")
  days_elapsed <- as.numeric(target_date - start_date)

  # 예측을 위한 데이터프레임 생성
  new_data <- data.frame(Days = days_elapsed)

  # predict 함수 사용
  pred_prof <- predict(model_prof, newdata = new_data)
  pred_stud <- predict(model_stud, newdata = new_data)
```

`predict(model, newdata)`는 `newdata`의 각 행에 적합된 식을 적용한다. `newdata`의 열 이름이 모델 공식의 설명변수 이름(`Days`)과 같아야 한다. 출력은 다음과 같다.

```text
==================================================
Target Date: 2021-11-22 
Days Elapsed since Start (2021-06-28): 147 days

[Predicted Weight Result]
Professor's Predicted Weight: 75.94 kg
Student's Predicted Weight:   59.36 kg
==================================================
```

`Assignment2_Q9.R`은 `target_date`만 `as.Date("2022-11-23")`으로 바꾼 스크립트이며, 513일에 대해 다음을 출력한다.

```text
==================================================
Target Date: 2022-11-23 
Days Elapsed: 513 days

[Long-term Prediction Result]
Professor's Predicted Weight: 41.56 kg
Student's Predicted Weight:   2.81 kg
==================================================
```

`predict()`에 `interval = "prediction"`을 주면 예측값과 함께 95% 예측 구간도 얻을 수 있다. 관측 범위에서 멀어질수록 구간이 넓어지므로 외삽의 불확실성을 수치로 확인할 수 있다.

---

<br>

## 8. Assignment2_Q8.R: 색을 지정한 산점도

```r
  p <- ggplot(plot_data, aes(x = Days, y = Weight, color = Group)) +
    # (1) 산점도 (Scatter Plot) - 실제 데이터 포인트
    geom_point(size = 2.5, alpha = 0.7) +

    # (2) 회귀 모델 (Fitted Models) - 선형 회귀선 (Linear Regression Line)
    # method = "lm": 선형 회귀 모델 사용
    # se = FALSE: 신뢰구간 표시 안 함 (선만 깔끔하게 보기 위해, 필요시 TRUE로 변경)
    geom_smooth(method = "lm", se = FALSE, size = 1.2) +

    # (3) 스타일 및 레이블 설정
    scale_color_manual(values = c("Professor" = "red", "Student" = "blue")) +
    labs(title = "Weight Loss Trajectory: Professor vs. Student",
         subtitle = "Scatter Plot with Linear Regression Models",
         x = "Days Elapsed (since 2021-06-28)",
         y = "Weight (kg)",
         color = "Subject") +
```

- 데이터 준비와 긴 형식 변환은 문제 6과 같고, 대상 열의 이름만 `Group`이다.
- `se = FALSE`로 신뢰 구간 띠를 그리지 않는다. 선 굵기를 `size`로 주면 ggplot2 3.4.0부터 `linewidth`를 쓰라는 경고가 나오지만 그림은 같다.
- `scale_color_manual()`은 그룹 값마다 색을 직접 지정한다. 이름 붙은 벡터 `c("Professor" = "red", "Student" = "blue")`로 그룹과 색을 짝짓는다.
- 이어지는 `theme()`은 제목을 굵게 하고 범례를 아래쪽에 둔다.

---

<br>

## 요약

| 개념 | 핵심 요약 |
|:-----|:-----|
| 패키지 반복 설치 | 이름을 문자열로 담은 변수를 `require()`와 `library()`에 넘기려면 `character.only = TRUE`가 필요하다. |
| 스크립트 기준 경로 | `sys.frame(1)$ofile`은 `source()`로 실행할 때만 스크립트 경로를 주며, `%||%`로 대체값을 둔다. |
| 볼록 껍질 | `split()`으로 그룹을 나누고 `chull()`이 돌려준 꼭짓점 행만 남겨 `geom_polygon()`으로 칠한다. |
| 차원 축소 함수 | `prcomp()$x`, `Rtsne()$Y`, `umap()$layout`이 2차원 좌표이며, Rtsne의 perplexity는 $(n - 1)/3$ 이하여야 한다. |
| 군집화 시각화 | `fviz_dend(k = 4)`는 트리를 잘라 색과 상자로 표시하고, `fviz_nbclust(method = "silhouette")`는 K별 평균 Silhouette 폭을 그린다. |
| 회귀와 예측 | 날짜의 차를 `as.numeric()`으로 날수로 바꾸고 `lm()`으로 적합하며, `predict()`의 `newdata`는 설명변수와 같은 열 이름을 가져야 한다. |

---

<br>

## 점검 문제

1. **패키지 이름 전달:** `p <- "ggplot2"`일 때 `library(p)`가 실패하는 이유와 고치는 방법을 쓰라.

   <details>
   <summary>정답</summary>

   `library()`는 인자를 따옴표 없는 이름으로 해석하므로 `library(p)`는 이름이 `p`인 패키지를 찾다가 실패한다. `library(p, character.only = TRUE)`로 쓰면 변수 `p`에 든 문자열 `"ggplot2"`를 패키지 이름으로 쓴다.

   </details>

2. **라벨 정규식:** `str_remove("Tuberculosis_Patient3", "[_0-9]+$")`의 결과를 쓰고, 패턴에서 `$`를 빼면 결과가 어떻게 달라지는지 설명하라.

   <details>
   <summary>정답</summary>

   결과는 `"Tuberculosis_Patient"`이다. 끝에서부터 밑줄이나 숫자가 이어지는 부분은 `3`뿐이기 때문이다. `$`를 빼면 패턴이 문자열 어디에서든 처음 나오는 밑줄과 숫자의 연속에 맞으므로, `Tuberculosis` 뒤의 `_`가 지워져 `"TuberculosisPatient3"`이 된다.

   </details>

3. **예측의 열 이름:** `predict(model_prof, newdata = data.frame(day = 147))`처럼 열 이름을 소문자로 쓰면 어떤 문제가 생기는가?

   <details>
   <summary>정답</summary>

   `predict()`는 모델 공식의 설명변수 이름 `Days`로 `newdata`에서 열을 찾는다. `day`라는 열만 있으면 `Days`를 찾지 못해 오류가 나거나, 같은 이름의 변수가 환경에 있으면 그 값을 써서 의도와 다른 결과를 낸다. 열 이름을 `Days`로 맞춰야 한다.

   </details>
