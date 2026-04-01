# Chapter 06 — Supervised Learning

> **Last Updated:** 2026-04-01

> **Prerequisites**: [Programming Language] R programming (Ch 1-5). [Statistics] Modeling concepts (Ch 5).
>
> **Learning Objectives**:
> 1. Apply classification algorithms (decision trees, SVM, k-NN)
> 2. Evaluate classifier performance using confusion matrices and ROC curves
> 3. Handle imbalanced datasets and apply ensemble methods

---

## Table of Contents

1. [Definition of Classification](#1-definition-of-classification)
2. [Classification vs. Prediction](#2-classification-vs-prediction)
3. [Classification Worked Example](#3-classification-worked-example)
4. [General Classification Process](#4-general-classification-process)
5. [Training Set and Test Set](#5-training-set-and-test-set)
6. [Overfitting](#6-overfitting)
7. [Validation Methods](#7-validation-methods)
8. [Measuring Model Performance](#8-measuring-model-performance)
9. [K-Nearest Neighbors (KNN)](#9-k-nearest-neighbors-knn)
10. [Summary](#summary)

---

<br>

## 1. Definition of Classification

### 1.1 Clustering vs. Classification

| Aspect | Clustering | Classification |
|--------|-----------|----------------|
| Learning type | **Unsupervised** learning | **Supervised** learning |
| Classes | Unknown a priori | **Predefined** |
| Goal | Class **discovery** (identification of new/unknown classes) | Class **prediction** (assignment into known classes) |
| Nature | Exploratory analysis | Predictive analysis |

- **Clustering** is the process of generating class variables (categorical response variables)
- **Classification** is the process of establishing a model with a class variable and predicting the class variable from the model

> **Key Point:** Clustering discovers unknown groups in data (unsupervised), while classification predicts membership in predefined groups (supervised).

---

<br>

## 2. Classification vs. Prediction

### 2.1 Classification

- Classifies data based on the constructed model using training set
- Uses values in a **categorical class** as the classifying attribute
- Assigns new data into predefined categories

### 2.2 Prediction

- Predicts data based on the constructed model using training set
- Works **regardless of the type of class variable** (continuous, categorical, survival time, etc.)

> **Key Point:** Depending on the type of outcome variable, classification and prediction are essentially the same process. Classification specifically refers to categorical outcomes, while prediction is the more general term.

---

<br>

## 3. Classification Worked Example

**Faculty Tenure Dataset:**

| NAME | RANK | YEARS | TENURED |
|------|------|-------|---------|
| Mike | Assistant Prof | 3 | No |
| Mary | Associate Prof | 7 | Yes |
| Bill | Professor | 2 | Yes |
| Jim | Assistant Prof | 7 | Yes |
| Dave | Associate Prof | 6 | No |
| Anne | Associate Prof | 3 | No |
| Jeff | Professor | 4 | ? |

**Extracted Rule:** IF rank = 'Professor' OR years > 6 THEN tenured = 'Yes'

**Classify Jeff:** Jeff is a Professor with 4 years. Since rank = 'Professor', the rule fires, and Jeff is classified as **"Yes" (tenured)**.

This example illustrates the full classification pipeline: training data with known labels produces a rule (model), which is then applied to classify a new, unseen instance.

---

<br>

## 4. General Classification Process

The classification analysis follows a structured pipeline:

```
Data
  |
  v
Pre-processing
  - Standardization
  - Normalization
  - Transformation
  |
  v
Classifier Construction  <---->  Tuning Parameters (feedback loop)
  - Feature selection
  - Algorithm
  - Training data
  |
  v
Classifier Evaluation
  - Error rate
  - Testing data
  |
  v
Class Prediction
  - New case
```

### 4.1 Two-Step Process

**Step 1: Model Construction**
- Describes a set of predetermined classes
- Each tuple/sample is assumed to belong to a predefined class, as determined by the class label attribute
- The set of tuples used for model construction: **training set**
- The model is represented as classification rules, decision trees, or mathematical formulae

**Step 2: Model Usage**
- For classifying future or unknown objects
- The known label of test samples is compared with the classified result from the model
- **Accuracy rate** = percentage of test set samples correctly classified by the model
- Test set must be **independent** of training set, otherwise overfitting will occur

> **Key Point:** The model is first built (induced) from training data, then applied (deduced) to classify new, unseen data. Training and testing data must remain separate to ensure reliable evaluation.

---

<br>

## 5. Training Set and Test Set

### 5.1 Definitions

| Set | Purpose |
|-----|---------|
| **Training set** | Data used **only** for building classification models (classifier) |
| **Test set** (Validation set) | Data used **only** to evaluate the performance of classification models |

### 5.2 Induction and Deduction

1. **Induction**: A learning algorithm processes the training set to learn and produce a model
2. **Deduction**: The learned model is applied to the test set to make predictions

> **Key Point:** If data is used without distinguishing between training and test sets, the model will likely overfit — performing well on known data but poorly on new, unseen data.

---

<br>

## 6. Overfitting

### 6.1 Definition

In statistics, overfitting is *"the production of an analysis that corresponds too closely or exactly to a particular set of data, and may therefore fail to fit additional data or predict future observations reliably."*

- An overfitted model contains more parameters than can be justified by the data (**overparameterization**)
- In machine learning, this phenomenon is sometimes called **overtraining**

### 6.2 Why Overfitting Happens

- Training data contains information about regularities in the mapping from input to output, but it also contains **noise**
- The target values may be unreliable
- There is **sampling error**: accidental regularities appear just because of the particular training cases chosen
- When fitting a model, it cannot tell which regularities are real and which are caused by sampling error, so it fits both kinds
- If the model is very flexible, it can model the sampling error really well — this is a disaster

### 6.3 Overfitting vs. Underfitting

| Problem | Description |
|---------|-------------|
| **Overfitting** | Too much fit to the training set, resulting in poor prediction on real new data |
| **Underfitting** | Model is too simple; both training and test errors are large |

### 6.4 Overfitting in Regression

Three fitting approaches compared:

| Method | Fit to Training Data | Generalization |
|--------|---------------------|----------------|
| **Linear** (y = beta_0 + beta_1 * x) | Moderate | Good |
| **Quadratic** (y = beta_0 + beta_1 * x + beta_2 * x^2) | Better | Better |
| **Piecewise linear** (non-parametric) | Perfect | Poor (overfitting) |

- The key question is not which method best fits the data, but: **"How well are you going to predict future data drawn from the same distribution?"**
- The test set method: randomly choose ~30% of data as a test set, train on the remainder, then evaluate using Mean Squared Error (MSE) on the test set

### 6.5 Specific MSE Comparison Values

**Test-set method:**

| Model | MSE |
|-------|-----|
| Linear | 2.4 |
| Quadratic | 0.9 |
| Piecewise | 3.2 |

**LOOCV method:**

| Model | MSE |
|-------|-----|
| Linear | 2.12 |
| Quadratic | 0.962 |
| Piecewise | 3.33 |

Both methods confirm that the **quadratic model is best** — it achieves the lowest test error despite not fitting the training data perfectly (unlike piecewise which interpolates exactly but generalizes worst).

### 6.6 Overfitting Visual Description

The characteristic signature of overfitting is visible when plotting error vs. model complexity:

- **Training error**: monotonically **decreasing** as model complexity increases (more parameters always fit training data better)
- **Test error**: **U-shaped** — initially decreasing as the model captures real patterns, then increasing as the model starts fitting noise

The point where training and test error curves **diverge** marks the onset of overfitting. The optimal model complexity is at the minimum of the test error curve.

> **Key Point:** A model that fits training data perfectly (like piecewise interpolation) often performs poorly on new data. The goal is to find the right balance of model complexity that generalizes well.

---

<br>

## 7. Validation Methods

### 7.1 Comparison of Methods

| Method | Downside | Upside |
|--------|----------|--------|
| **Test-set** | Variance: unreliable estimate of future performance | Cheap |
| **Leave-one-out (LOOCV)** | Expensive; has some weird behavior | Does not waste data |
| **10-fold** | Wastes 10% of data; 10 times more expensive than test set | Only wastes 10%; only 10 times more expensive instead of R times |
| **3-fold** | Wastier than 10-fold; more expensive than test set | Slightly better than test-set |
| **R-fold** | Identical to Leave-one-out | - |

### 7.2 Leave-One-Out Cross Validation (LOOCV)

Algorithm:
1. For k = 1 to R (number of data points):
   - Let (x_k, y_k) be the k-th record
   - Temporarily remove (x_k, y_k) from the dataset
   - Train on the remaining R-1 datapoints
   - Note the error for (x_k, y_k)
2. Report the mean error

$$CV_{(n)} = \frac{1}{n} \sum_{i=1}^{n} MSE_i$$

Properties:
- Far less bias; tends not to overestimate the test error rate
- Always yields the same results (no randomness in splits)
- Computationally intensive (model must be fit n times)
- Shortcut for OLS: CV_(n) = (1/n) * sum((Y_i - Y_hat_i) / (1 - h_i))^2

### 7.3 K-Fold Cross-Validation

- Used because LOOCV is computationally intensive
- Randomly divide the data set into **K folds** (typically K = 5 or 10)
- Each fold takes a turn as the validation set while the remaining K-1 folds serve as training data
- The MSE is computed on the held-out fold each time
- Average the K estimates to get the final validation error rate

$$CV_{(K)} = \sum_{k=1}^{K} \frac{n_k}{n} MSE_k$$

### 7.4 Bias-Variance Trade-off

- LOOCV is more computationally intensive than K-fold CV
- LOOCV has **less bias** (preferred from bias reduction perspective when K < n)
- LOOCV has **higher variance** than K-fold CV (when K < n)
- We tend to use K-fold CV with **K = 5 or K = 10**, as these values yield test error rate estimates that balance bias and variance

> **Key Point:** LOOCV is a special case of K-fold cross-validation where K = n. In practice, K = 5 or K = 10 provides a good bias-variance trade-off and is computationally feasible.

---

<br>

## 8. Measuring Model Performance

### 8.1 Hypothesis Testing Framing

The confusion matrix originates from hypothesis testing. Statistical test results either reject or fail to reject the null hypothesis:

- **H_0 (signal absent)**: The null hypothesis — no effect, no signal
- **H_1 (signal present)**: The alternative hypothesis — effect or signal exists

|  | H_1: Signal Present | H_0: Signal Absent |
|--|---------------------|-------------------|
| **Detection** | True Positive (TP) | False Positive (FP) — Type I error |
| **Null Result** | False Negative (FN) — Type II error | True Negative (TN) |

Key connections:
- **TPF (True Positive Fraction) = Sensitivity = Power** = TP / (TP + FN) — the probability of correctly detecting a true signal
- **FPF (False Positive Fraction) = 1 - Specificity** = FP / (FP + TN) — the probability of falsely detecting a signal when none exists

### 8.2 Primary Measures

| Measure | Formula | Also Known As |
|---------|---------|---------------|
| **TPR** (True Positive Rate) | TP / (TP + FN) | Sensitivity, Power, Recall, Hit Rate |
| **TNR** (True Negative Rate) | TN / (TN + FP) | Specificity |
| **PPV** (Positive Predictive Value) | TP / (TP + FP) | Precision |
| **NPV** (Negative Predictive Value) | TN / (TN + FN) | - |

### 8.3 Error Measures

| Measure | Formula | Relationship |
|---------|---------|-------------|
| **FNR** (False Negative Rate) | FN / (FN + TP) | = 1 - TPR (Miss Rate) |
| **FPR** (False Positive Rate) | FP / (FP + TN) | = 1 - TNR (Fall-out) |
| **FDR** (False Discovery Rate) | FP / (FP + TP) | = 1 - PPV |
| **FOR** (False Omission Rate) | FN / (FN + TN) | = 1 - NPV |

### 8.4 Overall Performance

| Measure | Formula |
|---------|---------|
| **ACC** (Accuracy) | (TP + TN) / (TP + TN + FP + FN) |
| **ERR** (Error Rate) | (FP + FN) / (TP + TN + FP + FN) = 1 - ACC |

> **Key Point:** Sensitivity (TPR) and specificity (TNR) are the most widely used measures in statistics and data science. Understanding the confusion matrix is essential for evaluating any classification model.

---

<br>

## 9. K-Nearest Neighbors (KNN)

### 9.1 Overview

- A simple heuristic classification algorithm
- Classifies a new data point based on the **majority class among its K nearest neighbors**
- Huge advantage: **multiple classes** can be considered
- The choice of K affects model complexity:
  - Small K: more flexible, risk of overfitting
  - Large K: smoother decision boundary, risk of underfitting

### 9.2 Distance Metric

KNN determines "nearest" using a distance metric, typically **Euclidean distance**:

$$d(\mathbf{x}, \mathbf{y}) = \sqrt{\sum_{i=1}^{n} (x_i - y_i)^2}$$

The algorithm computes the distance from the new point to every training point, then selects the K closest ones.

### 9.3 Visual Intuition

Consider classifying a green circle (?) with two classes: blue squares and red triangles.
- **K = 3** (inner circle): The 3 nearest neighbors might be 2 red triangles + 1 green circle, leading to classification as "triangle"
- **K = 7** (outer circle): The 7 nearest neighbors might include 4 blue squares + 3 red triangles, flipping the classification to "square"

The choice of K fundamentally changes the decision boundary.

### 9.4 Instance-Based (Lazy) Learning

KNN is called **instance-based** or **lazy learning** because:
- It does **not build an explicit model** during training — it simply **stores all training data**
- All computation is deferred to classification time
- **Computational cost**: high at prediction time because it must compute distances to all stored training points for every new query
- **Memory cost**: must store the entire training dataset

> **Key Point:** KNN is an instance-based (lazy) learning algorithm that makes no assumptions about the underlying data distribution. It simply stores training data and classifies new points by finding the nearest neighbors.

---

<br>

## Summary

| Concept | Key Point |
|---------|-----------|
| Clustering vs. Classification | Clustering is unsupervised (discovers groups); classification is supervised (predicts predefined groups) |
| Classification vs. Prediction | Essentially the same; classification specifically refers to categorical outcomes |
| Two-step process | Step 1: model construction from training set; Step 2: model usage for prediction |
| Training vs. Test set | Training set builds the model; test set evaluates it; they must be independent |
| Overfitting | Model fits training data too closely, fails to generalize; caused by overparameterization |
| Underfitting | Model is too simple; both training and test errors are large |
| LOOCV | Leave one observation out, train on rest, repeat n times; low bias, high variance |
| K-Fold CV | Divide data into K folds; K = 5 or 10 recommended for bias-variance balance |
| Confusion matrix | TP, TN, FP, FN form the basis for accuracy, sensitivity, specificity, and precision |
| KNN | Classifies based on majority vote of K nearest neighbors; supports multiple classes |
