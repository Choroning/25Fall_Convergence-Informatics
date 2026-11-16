# HW2 Assignment Handout — Unsupervised Learning

[Repository Guide](../../../README.md) | [English](Assignment.md) | [한국어](Assignment.ko.md)

> **Last Updated:** 2026-11-16

This is the second assignment of Convergence Informatics. It implements convergence informatics with real biomedical data, produced by cutting-edge technology used in actual research, and unsupervised learning: it classifies people according to various diseases and infers the relationship between diseases through R programming. It also applies basic supervised learning with a linear model to real data, aiming to become familiar with linear modeling through R programming.

- **Submission:** Compress and submit the report with the answers to the problems below and the entire R code (.R files) you wrote. The compressed file (.zip) must be named `HW2_YourID_Yourname.zip`.
- **Execution:** The R code should be executable when the TA runs it.
- **Collaboration:** You can consult with a friend, but copying the R code is absolutely prohibited, and the analysis method can never be the same.

---

<br>

## Data and Loading

Unzipping the compressed file downloaded from the LMS gives three data files. In this repository they are in the [`data/`](../data/) folder of the assignment.

| File | Contents | Problems |
|:-----|:-----|:-----|
| `1.Homework2_OriginalData.tsv` | Gene expression data measuring 16,273 features for 21 patients with 7 diseases (3 per disease). The first column `sampleName` holds sample names made of the disease name and the patient number, such as `COVID19_Patient1` | Problems 1-5 |
| `2.Homework2_FilteredData.tsv` | Gene expression data for the same 21 patients with the features reduced to 100 | Problems 1-5 |
| `HW2_Data3.xlsx` | Daily records (`Date`) of the weights (`ProfWeight_Kg`, `StudentWeight_Kg`), diets, and exercise of a professor and a student (2021-06-28 ~ 08-31, 65 days) | Problems 6-9 |

*Table 1. Data files of the assignment*

By placing the two TSV files in your working directory (`setwd(XXX)`) and using the `fread()` function of the data.table package as follows, you can load the data.

```r
library(data.table)

dataOriginal <- data.frame(fread("1.Homework2_OriginalData.tsv",
    sep = "\t", head = T, stringsAsFactor = F))

dataFiltered <- data.frame(fread("2.Homework2_FilteredData.tsv",
    sep = "\t", head = T, stringsAsFactor = F))
```

There are many ways to import the downloaded data into the RStudio working environment, so get used to the different ways by referring to Googling or the course textbooks, such as [https://rafalab.github.io/dsbook/importing-data.html](https://rafalab.github.io/dsbook/importing-data.html). The final exam is also a practical exam, so you must study how to import data.

---

<br>

## Problems 1-5: Gene Expression Data

Problems 1-5 are based on `1.Homework2_OriginalData.tsv` or `2.Homework2_FilteredData.tsv`.

### Problem 1

After performing PCA, t-SNE, and UMAP analysis on both data, plot the first two dimensional vectors of each. When drawing a plot, fill different colors depending on the disease. There are 3 samples for each disease.

- **To submit:** PCA, t-SNE, and UMAP plots for `dataOriginal` and PCA, t-SNE, and UMAP plots for `dataFiltered`

### Problem 2

Are there any significant differences in the results between the two data? What is the reason? If so, what data should be used?

### Problem 3

Perform clustering analysis using hierarchical clustering. Find the parameters (distance metric, linkage method, and others) that give the format most similar to the dimension reduction result. On the dendrogram, cut and mark the optimal number of clusters you think.

- **To submit:** Dendrogram

### Problem 4

Perform clustering analysis using K-means clustering based on Euclidean distance. Find the optimal number of clusters K by changing K from 2 to 10 based on the Silhouette score, and draw a plot of the Silhouette score.

- **To submit:** Silhouette plot based on the K-means clustering

### Problem 5

Based on all of your analysis above, feel free to interpret what the data is saying from the informatician standpoint. If possible, explain using the plots drawn in R as evidence, and complete this question within 2 pages. You may discuss which unsupervised learning methods are good, how many clusters fit, the relationship between diseases, the possibility of disease prediction modeling, and so on.

---

<br>

## Problems 6-9: Weight Loss Data

Problems 6-9 are based on `HW2_Data3.xlsx`.

### Problem 6

This is a record of weight loss during the summer vacation of 2021. Perform predictive modeling of the professor's and the student's weight changes, respectively. What is the best model established from the professor's and the student's data, respectively? Also, through inferred statistical comparison, which of the two had the faster weight loss effect? It must be interpreted through a comparison of estimated statistics.

- **To submit:** Established model for the professor, established model for the student, and interpretation of the estimated models

### Problem 7

If they continued to diet from that time until today (2021-11-22), what is their predicted weight?

- **To submit:** Predicted weights of the professor and the student on 2021-11-22

### Problem 8

Visualize the given data through scatter plots and represent the best models estimated for the professor and the student, respectively, in different colors. The hint is [https://rafalab.github.io/dsbook/regression.html](https://rafalab.github.io/dsbook/regression.html).

- **To submit:** Scatter plot with fitted models

### Problem 9

If they continued to diet from that time until 2022-11-23, what is their predicted weight?

- **To submit:** Predicted weights of the professor and the student on 2022-11-23 and an interpretation of the model (within 1 page). For the interpretation, consider the potential pitfalls of simple linear regression based on these results.

---

<br>

Solve the problems first; the [assignment explanation](../Assignment-Explanation.md) then gives the answers and solutions, and the [code walkthrough](../Code-Walkthrough.md) gives all the code written.
