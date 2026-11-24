# HW3 Assignment Handout — Supervised Learning

[Repository Guide](../../../README.md) | [English](Assignment.md) | [한국어](Assignment.ko.md)

> **Last Updated:** 2026-11-24

This is the third assignment of Convergence Informatics. It consists of three problems: designing a model that predicts a specific disease from gene expression data, designing a model that predicts COVID-19 from 10 feature values, and identifying a serial killer in a DNA database. Read the questions and answer them carefully.

- **Deliverables:** The report (.docx) with your answers and the entire R code (.R files) used for the answers.
- **Answer language:** Write your answers in Korean or English.
- **Execution:** The R code should be executable when the TA runs it.
- **Partial score:** There is a partial score, so even if you cannot resolve a problem completely, try it as far as you can.
- **Points:** Problem 1 is worth 40 points, Problem 2 is worth 40 points, and Problem 3 is worth 30 points.

---

<br>

## Data

The data files of the assignment are in the [`data/`](../data/) folder of the assignment.

| File | Contents | Problems |
|:-----|:-----|:-----|
| `Data1.tsv` | 16,273 feature values for 21 patients with 7 diseases. The first column `sampleName` holds sample names made of the disease name and the patient number, such as `Asthma_Patient1` | Problem 1 |
| `Data2.tsv` | 10 feature values (`F1`-`F10`) and COVID-19 status (`Disease`: `COVID19` or `Healthy`) for 999 people | Problem 2 |
| `Data3_DNA_Database.csv` | DNA information (`Subject` and `DNA_1`-`DNA_1000`) of 2,178 DNA criminals living in Seoul | Problem 3 |
| `Data3_DNA_Query.csv` | One row of DNA information of the targeted criminal (same columns) | Problem 3 |

*Table 1. Data files of the assignment*

---

<br>

## Problem 1. Asthma Prediction Model (40 Points)

`Data1.tsv` contains information on 16,273 features for a total of 21 patients (7 diseases in total). Develop an artificial intelligence model that can accurately predict Asthma based on the data. Evaluate it using LOOCV and describe the final prediction accuracy in your answer. Scores are given differentially in order of prediction accuracy. However, if the prediction accuracy is measured inaccurately or unfairly, the score will be the lowest score among the submitters instead of 0. Naturally, a poor analysis model is given a score of 0.

- **Tip:** Since the dimension is larger than the number of samples, actively use the dimension reduction models learned this semester.
- **Length:** The answer is limited to 1 page.

---

<br>

## Problem 2. COVID-19 Prediction Model (40 Points)

Load the `Data2.tsv` file. It is data on 10 feature values collected from a total of 999 people and whether they are positive for COVID-19. Based on this data, construct the best model for predicting COVID-19 from the 10 features.

### Problem 2-1 (10 Points)

Before modeling, visualize the 999 individuals in the given data at once to determine whether COVID-19 patients can be distinguished from normal people based on the given data.

- **Hint:** Since the features are 10-dimensional, the data have to be processed first through a method learned in class, and it is better to show the disease information in different colors.

### Problem 2-2 (20 Points)

Using at least 8 different models, find the best model in terms of accuracy.

### Problem 2-3 (10 Points)

Using at least 8 different models, find the best model in terms of sensitivity.

---

<br>

## Problem 3. Identification with DNA Information (30 Points)

Load the `Data3_DNA_Database.csv` and `Data3_DNA_Query.csv` files. As the Hwaseong serial murder case reported in 2019 shows ([CNN article](https://edition.cnn.com/2019/10/04/asia/south-korean-serial-murder-confessed-intl-hnk-scli/index.html), [Wikipedia: Lee Choon-jae](https://en.wikipedia.org/wiki/Lee_Choon-jae)), the informatics technology learned in class is being applied in various fields.

- `Data3_DNA_Database.csv`: The database of the information of 2,178 DNA criminals living in Seoul.
- `Data3_DNA_Query.csv`: The file containing the targeted criminal's DNA information.

Apply the skills learned this semester to identify who the serial killer is. All the given data have already been pre-processed (all values are real numbers). DNA information is characterized by very little information that changes over several centuries, meaning that having the same value across all features is more likely to be a target.

### Problem 3-1 (10 Points)

What analysis methodology did you use? Why did you use it?

### Problem 3-2 (10 Points)

Give an overview of the modeling you performed and draw a conclusion.

### Problem 3-3 (10 Points)

Show visualization evidence that supports your results.

---

<br>

Solve the problems first; the [assignment explanation](../Assignment-Explanation.md) then gives the answers and solutions, and the [code walkthrough](../Code-Walkthrough.md) gives all the code written.
