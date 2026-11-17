# HW2 Code Walkthrough — Unsupervised Learning

[Repository Guide](../../README.md) | [English](Code-Walkthrough.md) | [한국어](Code-Walkthrough.ko.md)

> **Last Updated:** 2026-11-17

> **Learning Objectives:**
> 1. Install and load a list of packages with a loop and find the data folder relative to the location of the script
> 2. Extract two-dimensional coordinates from the results of `prcomp()`, `Rtsne()`, and `umap()`, plot them with ggplot2, and arrange several plots on one screen
> 3. Visualize clustering results with `dist()`, `hclust()`, and factoextra's `fviz_dend()` and `fviz_nbclust()`
> 4. Read an Excel file with readxl, convert dates to elapsed days, and fit and predict with regression models using `lm()`, `summary()`, and `predict()`

---

## Table of Contents

- [1. File Structure and How to Run](#1-file-structure-and-how-to-run)
- [2. Parts Common to the Seven Scripts](#2-parts-common-to-the-seven-scripts)
  - [2.1 Header and Package Setup](#21-header-and-package-setup)
  - [2.2 Setting the Working Directory](#22-setting-the-working-directory)
- [3. Assignment2_Q1.R: Dimension Reduction Visualization](#3-assignment2_q1r-dimension-reduction-visualization)
  - [3.1 Legend Extraction Function](#31-legend-extraction-function)
  - [3.2 Scatter Plot Function with Filled Convex Hulls](#32-scatter-plot-function-with-filled-convex-hulls)
  - [3.3 Function That Analyzes One Dataset](#33-function-that-analyzes-one-dataset)
  - [3.4 Execution and Layout](#34-execution-and-layout)
- [4. Assignment2_Q3.R: Dendrogram](#4-assignment2_q3r-dendrogram)
- [5. Assignment2_Q4.R: Silhouette Plot](#5-assignment2_q4r-silhouette-plot)
- [6. Assignment2_Q6.R: Fitting the Regression Models](#6-assignment2_q6r-fitting-the-regression-models)
  - [6.1 Data Preparation](#61-data-preparation)
  - [6.2 Model Fitting and Output](#62-model-fitting-and-output)
  - [6.3 Visualization with Confidence Bands](#63-visualization-with-confidence-bands)
- [7. Assignment2_Q7.R and Assignment2_Q9.R: Prediction for a Given Date](#7-assignment2_q7r-and-assignment2_q9r-prediction-for-a-given-date)
- [8. Assignment2_Q8.R: Scatter Plot with Assigned Colors](#8-assignment2_q8r-scatter-plot-with-assigned-colors)
- [Summary](#summary)
- [Self-Check Questions](#self-check-questions)

---

<br>

## 1. File Structure and How to Run

> **Try It First:** This document contains the complete code and line-by-line explanations. Solve the problems in the [assignment handout](Original/Assignment.md) yourself before reading on.

The seven R scripts in `Solution/` correspond one to one to the problems, and the data are in the `data/` folder of the assignment.

| File | Problem | Input Data | Output |
|:-----|:-----|:-----|:-----|
| [`Assignment2_Q1.R`](Solution/Assignment2_Q1.R) | Problem 1 | `1.Homework2_OriginalData.tsv`, `2.Homework2_FilteredData.tsv` | One figure arranging 6 plots |
| [`Assignment2_Q3.R`](Solution/Assignment2_Q3.R) | Problem 3 | `2.Homework2_FilteredData.tsv` | Horizontal dendrogram |
| [`Assignment2_Q4.R`](Solution/Assignment2_Q4.R) | Problem 4 | `2.Homework2_FilteredData.tsv` | Silhouette plot |
| [`Assignment2_Q6.R`](Solution/Assignment2_Q6.R) | Problem 6 | `HW2_Data3.xlsx` | Coefficient tables, $R^2$, comparison sentence, and a plot with confidence bands |
| [`Assignment2_Q7.R`](Solution/Assignment2_Q7.R) | Problem 7 | `HW2_Data3.xlsx` | Predicted weights on 2021-11-22 |
| [`Assignment2_Q8.R`](Solution/Assignment2_Q8.R) | Problem 8 | `HW2_Data3.xlsx` | Scatter plot with regression lines |
| [`Assignment2_Q9.R`](Solution/Assignment2_Q9.R) | Problem 9 | `HW2_Data3.xlsx` | Predicted weights on 2022-11-23 |

*Table 1. Structure of the HW2 scripts*

The scripts find the data folder relative to their own folder, so run them with `source()`. If R was opened at the repository root, run them as follows; in RStudio, open a script and press the Source button.

```r
source("Coursework/HW02_Unsupervised-Learning/Solution/Assignment2_Q1.R")
```

---

<br>

## 2. Parts Common to the Seven Scripts

### 2.1 Header and Package Setup

Lines 1-12 of `Assignment2_Q1.R` serve as the example.

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

- Lines 1-4 are a Doxygen-style header with the file name, a one-line description, the author, and the date.
- `setRepositories(ind = 1:7)` widens the repositories where `install.packages()` looks for packages to seven, including CRAN, the Bioconductor repositories, and R-Forge.
- The package names are collected in the character vector `pkg_list` and processed one by one with a `for` loop. `require()` and `library()` normally take an unquoted name, so `character.only = TRUE` is needed to use the string in the variable `p` as a package name. When `require()` returns `FALSE` (the package is not installed), the package is installed and then loaded.
- `Assignment2_Q3.R` and `Assignment2_Q4.R` use the same loop, and the four scripts on the weight data write one line per package, such as `if (!require("readxl")) install.packages("readxl")`.

### 2.2 Setting the Working Directory

```r
# 2. 작업 경로 설정
WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../data")
if(dir.exists(WORK_DIR)) setwd(WORK_DIR) else warning("경로를 확인하세요.")
```

- When a script is run with `source()`, the first frame of the call stack is the execution environment of `source()`, and its variable `ofile` holds the script path. `sys.frame(1)$ofile` retrieves this path.
- `dirname()` returns the folder of the path without the file name (`.../Solution`), and `file.path(..., "../data")` builds the path of the `data/` folder next to it. `%||%` is an operator built into R since 4.4.0 that returns the right value when the left value is `NULL`.
- Only after `dir.exists()` confirms that the folder exists does `setwd()` change the working directory; otherwise only a warning is raised. Later file names are resolved relative to this folder. `Assignment2_Q7.R` uses `setwd(WORK_DIR)` without the check, so it stops with an error if the folder does not exist.

> **Caution:** This approach works only when the script is run with `source()`. If it is run with `Rscript Assignment2_Q1.R` or `source()` is called inside another function, the first frame has no `ofile` and the path is not found. In that case, put the path of the data folder into `WORK_DIR` directly.

---

<br>

## 3. Assignment2_Q1.R: Dimension Reduction Visualization

### 3.1 Legend Extraction Function

```r
get_legend <- function(myggplot){
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  if(length(leg) > 0) return(tmp$grobs[[leg]]) else return(NULL)
}
```

For the six plots to share one legend, the legend alone must be detached from one plot. `ggplot_build()` computes a ggplot object into drawable data, and `ggplot_gtable()` turns it into a table of grid graphical objects (grobs). Among its components (`tmp$grobs`), the one named `"guide-box"` is the legend, so the function finds its position and returns it.

### 3.2 Scatter Plot Function with Filled Convex Hulls

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

- `split(df, df[[group_col]])` makes a list of the data frame split by disease, and `lapply()` applies a function to each piece.
- `chull(x, y)` returns the row numbers of the points forming the convex hull of the planar points, in order around the hull. Keeping only those rows gives the vertices of a polygon, and `do.call(rbind, ...)` combines the results of all diseases into one data frame.
- `aes_string()` builds aesthetic mappings from column names given as strings. It is used to pass column names as function arguments, and from ggplot2 3.0.0 on it gives a deprecation warning. The same can be done with `aes(x = .data[[x_col]], y = .data[[y_col]], ...)`.
- `geom_polygon()` fills the convex hulls with transparency 0.2, and `geom_point()` draws the points on top. The legend is placed at the bottom so that `get_legend()` can extract it, and it is hidden in each plot later.

### 3.3 Function That Analyzes One Dataset

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

- `read.delim()` reads a tab-separated file, and `row.names = 1` uses the first column `sampleName` as row names. The result is a data frame of 21 rows (samples) × the number of features as columns.
- `scale()` returns a matrix with the mean subtracted from each column and divided by the standard deviation. Since the rows are samples, each gene is standardized.
- `Rtsne()` raises an error when identical rows exist, so `duplicated()` finds duplicate rows and removes them. These data have no duplicate rows, so all 21 rows remain.
- `str_remove(string, pattern)` removes the part matching a regular expression. `"[_0-9]+$"` is a run of underscores and digits at the end, so `COVID19_Patient1` becomes `COVID19_Patient`. Only the digit `1` of the final `Patient1` is removed, and `Patient` remains because it consists of letters.

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

- Since the data are already standardized, the centering and scaling of `prcomp()` are turned off.
- `fit_pca$sdev` is the standard deviation of each principal component, so its square is the variance (eigenvalue). Dividing it by the total, multiplying by 100, and rounding to one decimal place gives the explained variance ratio (%).
- `fit_pca$x` is the matrix of principal component scores of each sample, and its first two columns are used as the x and y coordinates.

```r
  # 2) t-SNE
  set.seed(2025)
  perp_n <- floor((nrow(mx_scaled) - 1) / 3)
  fit_tsne <- Rtsne(mx_scaled, dims = 2, perplexity = perp_n, check_duplicates = FALSE)
  df_tsne <- data.frame(X = fit_tsne$Y[,1], Y = fit_tsne$Y[,2], Group = y_labels)

  p2 <- create_plot(df_tsne, "X", "Y", "Group",
                    paste0("t-SNE (", label_prefix, ")"), "t-SNE 1", "t-SNE 2")
```

- `Rtsne()` raises an error when `nrow - 1 < 3 * perplexity`, so the perplexity is set to the largest allowed value $\lfloor (21 - 1)/3 \rfloor = 6$.
- Since duplicate rows were already removed, `check_duplicates = FALSE` skips the check.
- By its defaults `pca = TRUE` and `initial_dims = 50`, `Rtsne()` first reduces the dimension with PCA and then runs t-SNE. With 21 samples there are at most 21 principal components, so practically all of them are used.
- The `$Y` of the result holds the two-dimensional embedding coordinates.

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

The `umap()` of the umap package lets settings be changed through arguments, and here the number of neighbors is stated explicitly as 15, the same as the default. The `$layout` of the result holds the embedding coordinates. The function returns the three plots as a list.

### 3.4 Execution and Layout

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

- The same function is applied to both datasets, and one legend is extracted from the PCA plot of the original data.
- `c()` joins the two lists into a list of 6 plots, and adding `theme(legend.position = "none")` to each plot hides its legend.
- gridExtra's `arrangeGrob()` builds an object grouping the 6 plots in 2 rows and 3 columns, and the outer `grid.arrange()` stacks this group and the legend vertically with a height ratio of 9:1 and adds a bold title on top.
- If either file is not found, `analyze_dataset()` returns `NULL`, so `stop()` halts the script. `&` is an element-wise logical AND, but for logical values of length 1 it gives the same result as `&&`.

---

<br>

## 4. Assignment2_Q3.R: Dendrogram

```r
  raw_dataset <- read.delim(target_file, header = TRUE, row.names = 1)

  # [Standardization] 데이터 표준화 (Z-score)
  z_score_matrix <- scale(raw_dataset)

  # 4. 계층적 군집 분석 (Hierarchical Clustering)
  # Distance: Euclidean, Linkage: Ward.D2
  dist_metric <- dist(z_score_matrix, method = "euclidean")
  hierarchical_model <- hclust(dist_metric, method = "ward.D2")
```

- The filtered data are read and standardized. The code runs only when `if(file.exists(target_file))` finds the file and otherwise halts with `stop()`.
- `dist()` computes the distances between rows (samples) and returns a `dist` object holding the lower triangle of the 21 × 21 distance matrix.
- `hclust()` performs agglomerative hierarchical clustering. `"ward.D2"` squares the distances and merges by Ward's minimum variance criterion.

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

factoextra's `fviz_dend()` draws an `hclust` result as a ggplot2 dendrogram. `k = 4` cuts the tree into 4 clusters (by the same criterion as `cutree()`), and `k_colors = "jco"` colors each cluster with the Journal of Clinical Oncology palette. `rect = TRUE` and `rect_fill = TRUE` enclose each cluster in a semi-transparent box, and `horiz = TRUE` lays the tree horizontally so that long sample names are not cut off. Since the return value is a ggplot object, adding `theme()` can center the title, and `print()` draws it on screen. In the horizontal layout, `xlab` names the vertical axis and `ylab` names the horizontal axis (height).

---

<br>

## 5. Assignment2_Q4.R: Silhouette Plot

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

- `fviz_nbclust(data, clustering function, method = "silhouette", k.max = 10)` runs `kmeans()` for each K = 2, ..., 10, computes the average silhouette width with `silhouette()` of the cluster package, and draws it as a line plot. It draws a vertical dashed line at the K with the largest value and shows K = 1 as 0. The function calls `set.seed(123)` first, so the random initialization of `kmeans()` is the same in every run.
- The function name `kmeans` is passed as is as the second argument. In R, functions are values, so they can be arguments of other functions.
- Since the result is a ggplot object, `labs()` changes the title and axis labels and `theme_minimal()` is applied. The computed values are in `viz_silhouette$data`.
- The two `cat()` lines at the end of the script print a notice that the plot was created.

---

<br>

## 6. Assignment2_Q6.R: Fitting the Regression Models

### 6.1 Data Preparation

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

- readxl's `read_excel()` reads the first sheet as a tibble. The sheet has unnamed empty columns on the right, which produce messages such as `New names: ... -> ...8`, but only the three needed columns are selected, so the result is not affected.
- `na.omit()` removes rows with missing values. The 65 rows of these data have no missing values in the three columns.
- `read_excel()` reads dates as `POSIXct` including the time, so `as.Date()` keeps only the date. The difference of two `Date` values is a `difftime` object, and `as.numeric()` gives the number of days (0-64).

### 6.2 Model Fitting and Output

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

- `lm(y ~ x, data)` fits a simple linear regression by least squares. The left side of `~` in the formula is the response variable and the right side is the explanatory variable.
- `summary()` computes the estimates, standard errors, t values, and p-values of the coefficients, the coefficient of determination, and more. `coef(summary_prof)` extracts the coefficient table as a matrix, and `$r.squared` is $R^2$. The student's model is printed in the same way.

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

`coef(model)` is the vector (intercept, slope), so `[2]` is the slope. Both slopes are negative, so the smaller (more negative) one belongs to the steeper weight loss, and the `if` statement prints the matching sentence. For these data it prints the following.

```text
[Comparison Result]
Student's slope ( -0.1545 ) is steeper (more negative) than Professor's ( -0.0939 ).
Conclusion: The Student had a faster weight loss effect.
```

### 6.3 Visualization with Confidence Bands

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

- The wide format, with both people's weights in one row, is converted to the long format, with one weight of one person per row. The two data frames are stacked with `rbind()` and the subject is distinguished by the `Person` column, so the tidyr package is not needed.
- `geom_smooth(method = "lm", se = TRUE)` fits and draws a separate regression line for each color group and fills the line's 95% confidence band. This line is the same as the model fitted with `lm()`.
- The subtitle shows the two slopes to three decimal places.

---

<br>

## 7. Assignment2_Q7.R and Assignment2_Q9.R: Prediction for a Given Date

The two scripts prepare the data in the same way as Problem 6, refit the two models, and predict, changing only the target date. Lines 28-37 of `Assignment2_Q7.R` are as follows.

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

`predict(model, newdata)` applies the fitted equation to each row of `newdata`. The column names of `newdata` must match the explanatory variable name in the model formula (`Days`). The output is as follows.

```text
==================================================
Target Date: 2021-11-22 
Days Elapsed since Start (2021-06-28): 147 days

[Predicted Weight Result]
Professor's Predicted Weight: 75.94 kg
Student's Predicted Weight:   59.36 kg
==================================================
```

`Assignment2_Q9.R` is the script with only `target_date` changed to `as.Date("2022-11-23")`, and it prints the following for 513 days.

```text
==================================================
Target Date: 2022-11-23 
Days Elapsed: 513 days

[Long-term Prediction Result]
Professor's Predicted Weight: 41.56 kg
Student's Predicted Weight:   2.81 kg
==================================================
```

Giving `interval = "prediction"` to `predict()` also returns the 95% prediction interval along with the predicted value. The interval widens farther from the observed range, so the uncertainty of extrapolation can be checked numerically.

---

<br>

## 8. Assignment2_Q8.R: Scatter Plot with Assigned Colors

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

- The data preparation and long-format conversion are the same as in Problem 6, except that the subject column is named `Group`.
- `se = FALSE` draws no confidence bands. Giving the line width with `size` produces a warning from ggplot2 3.4.0 on to use `linewidth`, but the plot is the same.
- `scale_color_manual()` assigns a color to each group value directly. The named vector `c("Professor" = "red", "Student" = "blue")` pairs groups with colors.
- The following `theme()` makes the title bold and places the legend at the bottom.

---

<br>

## Summary

| Concept | Key Summary |
|:-----|:-----|
| Installing packages in a loop | Passing a variable holding a name as a string to `require()` and `library()` requires `character.only = TRUE`. |
| Script-relative path | `sys.frame(1)$ofile` gives the script path only when the script is run with `source()`, and `%||%` provides a fallback. |
| Convex hull | `split()` divides the groups, and only the vertex rows returned by `chull()` are kept and filled with `geom_polygon()`. |
| Dimension reduction functions | `prcomp()$x`, `Rtsne()$Y`, and `umap()$layout` hold the two-dimensional coordinates, and Rtsne's perplexity must be at most $(n - 1)/3$. |
| Clustering visualization | `fviz_dend(k = 4)` cuts the tree and marks it with colors and boxes, and `fviz_nbclust(method = "silhouette")` plots the average silhouette width for each K. |
| Regression and prediction | The difference of dates is converted to days with `as.numeric()` and fitted with `lm()`, and the `newdata` of `predict()` must have the same column name as the explanatory variable. |

---

<br>

## Self-Check Questions

1. **Passing a package name:** When `p <- "ggplot2"`, state why `library(p)` fails and how to fix it.

   <details>
   <summary>Answer</summary>

   `library()` interprets its argument as an unquoted name, so `library(p)` looks for a package named `p` and fails. Writing `library(p, character.only = TRUE)` uses the string `"ggplot2"` in the variable `p` as the package name.

   </details>

2. **Label regular expression:** Give the result of `str_remove("Tuberculosis_Patient3", "[_0-9]+$")`, and explain how the result changes if `$` is removed from the pattern.

   <details>
   <summary>Answer</summary>

   The result is `"Tuberculosis_Patient"`, because the only run of underscores or digits at the end is `3`. Without `$`, the pattern matches the first run of underscores and digits anywhere in the string, so the `_` after `Tuberculosis` is removed and the result is `"TuberculosisPatient3"`.

   </details>

3. **Column name for prediction:** What problem arises if the column name is written in lowercase, as in `predict(model_prof, newdata = data.frame(day = 147))`?

   <details>
   <summary>Answer</summary>

   `predict()` looks up the column in `newdata` by the explanatory variable name `Days` of the model formula. If only a column named `day` exists, `Days` is not found and an error occurs, or if a variable of the same name exists in the environment, its values are used and give an unintended result. The column name must be `Days`.

   </details>
