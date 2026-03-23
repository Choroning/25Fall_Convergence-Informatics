# Chapter 05 — Modeling

> **Last Updated:** 2026-03-23

---

## Table of Contents

1. [Definition of a Model](#1-definition-of-a-model)
2. [Mathematical and Statistical Models](#2-mathematical-and-statistical-models)
3. [Types of Probabilistic Models](#3-types-of-probabilistic-models)
4. [Regression Models](#4-regression-models)
5. [Linear Regression](#5-linear-regression)
6. [Least Squares Estimation](#6-least-squares-estimation)
7. [Correlation vs. Regression](#7-correlation-vs-regression)
8. [Map of Analytical Methods](#8-map-of-analytical-methods)
9. [Practical Prediction Example: Diet Journey](#9-practical-prediction-example-diet-journey)
10. [Summary](#summary)

---

## 1. Definition of a Model

A model is a **representative (artificial) one which describes real phenomena**.

Model, modeling, or modelling may refer to:

- **Conceptual model**: a representation of a system using general rules and concepts
- **Scientific model**: a simplified and idealized understanding of physical systems
- **Physical model**: a physical representation in three dimensions of an object, such as a globe or model airplane

> **Key Point:** In this course, we focus on mathematical/statistical models that describe relationships between variables using equations and probability.

---

## 2. Mathematical and Statistical Models

Mathematical and statistical models often describe **relationships between variables**.

### 2.1 Deterministic Models

- Hypothesize **exact relationships** (no randomness)
- Suitable when prediction error is negligible
- Example: Body Mass Index (BMI)

$$BMI = \frac{Weight\ (kg)}{Height\ (m)^2}$$

### 2.2 Probabilistic Models

- Hypothesize two components: a **deterministic** component and a **random error**
- Example: Systolic blood pressure (SBP) of newborns

$$SBP = 6 \times age(d) + \varepsilon$$

- Random error may be due to environmental factors other than age in days (e.g., birthweight)

> **Key Point:** Deterministic models assume exact relationships with no randomness, while probabilistic models include a random error term to account for unexplained variability.

---

## 3. Types of Probabilistic Models

Probabilistic models can be categorized into three types:

| Type | Description |
|------|-------------|
| **Regression Models** | Model the relationship between dependent and independent variables using equations |
| **Correlation Models** | Analyze the strength of linearity between two variables |
| **Other Models** | Additional probabilistic modeling approaches |

---

## 4. Regression Models

### 4.1 Definition

- Describes the **relationship between one dependent variable and explanatory variable(s)**
- Uses equations to set up the relationship
- Used mainly for **prediction and estimation**

### 4.2 Types of Variables

**Dependent variable (Y)**:
- Represents a particular phenomenon of interest
- Synonyms: response variable, outcome variable
- Notation: usually denoted as Y

**Independent variable (X)**:
- Variables that can affect the dependent variable
- Synonyms: explanatory variable, predictor
- Notation: usually denoted as X_1, ..., X_k

### 4.3 Types of Regression Models

Regression models are classified along two dimensions:

|  | Simple (1 explanatory variable) | Multiple (2+ explanatory variables) |
|--|---|----|
| **Linear** | Simple Linear Regression | Multiple Linear Regression |
| **Non-Linear** | Simple Non-Linear Regression | Multiple Non-Linear Regression |

> **Key Point:** Regression models require a numerical dependent (response) variable and one or more numerical or categorical independent (explanatory) variables.

---

## 5. Linear Regression

### 5.1 Linear Equation Review

The basic linear equation is:

$$Y = mX + b$$

Where:
- `m` = slope (change in Y / change in X)
- `b` = Y-intercept

### 5.2 Population Linear Regression Model

The relationship between variables is assumed to be a linear function:

$$Y_i = \beta_0 + \beta_1 X_i + \varepsilon_i$$

| Component | Meaning |
|-----------|---------|
| Y_i | Dependent (response) variable |
| beta_0 | Population Y-intercept |
| beta_1 | Population slope |
| X_i | Independent (explanatory) variable |
| epsilon_i | Random error |

### 5.3 Error Distribution Assumption

The random error term is assumed to follow a normal distribution:

$$\varepsilon_i \sim N(0, \sigma^2)$$

This means:
- Errors have **zero mean** (on average, the model is correct)
- Errors have **constant variance** sigma^2 (homoscedasticity)
- Errors are **normally distributed** around the regression line

This assumption is essential for statistical inference (hypothesis tests, confidence intervals) on the regression coefficients. The residuals (observed errors) should be checked against this assumption when validating a model.

### 5.4 Population vs. Sample

- **Population**: Unknown relationship Y_i = beta_0 + beta_1 * X_i + epsilon_i
- **Sample**: Estimated relationship Y_i = beta_hat_0 + beta_hat_1 * X_i + epsilon_hat_i
- We use sample data to estimate the unknown population parameters

> **Key Point:** The population model contains true (unknown) parameters, while the sample model uses estimated parameters (denoted with hat notation) derived from observed data.

---

## 6. Least Squares Estimation

### 6.1 Goal of Regression Modeling

The goal is to find the line that **best fits** the data by determining optimal values for the slope and intercept.

### 6.2 Visual Intuition for Fitting

- **Adjusting beta_0 (intercept)**: Trying different values of beta_0 is equivalent to **shifting the line up and down** the scatter plot. The slope stays constant while the entire line translates vertically.
- **Adjusting beta_1 (slope)**: Trying different values of beta_1 is equivalent to **changing the slope (steepness)** of the line, while beta_0 stays constant. The line rotates around the y-intercept.

### 6.3 Least Squares Method

"Best fit" means the difference between actual Y values and predicted Y values is minimized. Since positive differences offset negative ones, we use **squared errors**:

$$SSE = \sum_{i=1}^{n} (Y_i - \hat{Y}_i)^2 = \sum_{i=1}^{n} \hat{\varepsilon}_i^2$$

The least squares method minimizes the Sum of Squared Errors (SSE).

### 6.4 Deriving the OLS Estimators

The minimization problem is:

$$\min_{\hat{\beta}_0, \hat{\beta}_1} \sum_{i=1}^{N} (y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i)^2$$

Setting the partial derivatives equal to zero:

$$\frac{\partial W}{\partial \hat{\beta}_0} = \sum_{i=1}^{N} -2(y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i) = 0$$

$$\frac{\partial W}{\partial \hat{\beta}_1} = \sum_{i=1}^{N} -2x_i(y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i) = 0$$

### 6.5 OLS Formulas

Solving the partial differential equations gives us:

$$\hat{\beta}_0 = \bar{y} - \hat{\beta}_1 \bar{x}$$

$$\hat{\beta}_1 = \frac{\sum_{i=1}^{N}(x_i - \bar{x})(y_i - \bar{y})}{\sum_{i=1}^{N}(x_i - \bar{x})^2}$$

### 6.6 OLS Derivation Intermediate Steps

**Step 1: Solve for beta_hat_0 from the first equation:**

$$\frac{\partial W}{\partial \hat{\beta}_0} = \sum_{i=1}^{N} -2(y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i) = 0 \implies \hat{\beta}_0 = \bar{y} - \hat{\beta}_1 \bar{x}$$

**Step 2: Substitute beta_hat_0 into the second equation:**

$$\frac{\partial W}{\partial \hat{\beta}_1} = \sum_{i=1}^{N} -2x_i(y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i) = 0$$

Substituting beta_hat_0 = y_bar - beta_hat_1 * x_bar:

$$\sum_{i=1}^{N} x_i y_i - (\bar{y} - \hat{\beta}_1 \bar{x}) x_i - \hat{\beta}_1 x_i^2 = 0$$

**Step 3: Distribute the summation and solve for beta_hat_1:**

$$\sum x_i y_i - \bar{y} \sum x_i + \hat{\beta}_1 \bar{x} \sum x_i - \hat{\beta}_1 \sum x_i^2 = 0$$

$$\hat{\beta}_1 = \frac{\sum_{i=1}^{N}(x_i - \bar{x})(y_i - \bar{y})}{\sum_{i=1}^{N}(x_i - \bar{x})^2}$$

Note: This formula has a structure similar to the correlation coefficient formula.

### 6.7 Multiple Linear Regression (Matrix Form)

For multiple explanatory variables, define the matrix components:

$$\mathbf{y} = \begin{bmatrix} y_1 \\ y_2 \\ \vdots \\ y_n \end{bmatrix}, \quad \mathbf{X} = \begin{bmatrix} 1 & x_{11} & x_{12} & \cdots & x_{1k} \\ 1 & x_{21} & x_{22} & \cdots & x_{2k} \\ \vdots & \vdots & \vdots & \ddots & \vdots \\ 1 & x_{n1} & x_{n2} & \cdots & x_{nk} \end{bmatrix}, \quad \boldsymbol{\beta} = \begin{bmatrix} \beta_0 \\ \beta_1 \\ \vdots \\ \beta_k \end{bmatrix}, \quad \boldsymbol{\epsilon} = \begin{bmatrix} \epsilon_1 \\ \epsilon_2 \\ \vdots \\ \epsilon_n \end{bmatrix}$$

The model in matrix form: **y = X * beta + epsilon**

**Derivation of the normal equations:**

$$\sum \epsilon_i^2 = \boldsymbol{\epsilon}'\boldsymbol{\epsilon} = (\mathbf{y} - \mathbf{X}\boldsymbol{\beta})'(\mathbf{y} - \mathbf{X}\boldsymbol{\beta})$$

Expanding:

$$= \mathbf{y}'\mathbf{y} - \hat{\boldsymbol{\beta}}'\mathbf{X}'\mathbf{y} - \mathbf{y}'\mathbf{X}\hat{\boldsymbol{\beta}} + \hat{\boldsymbol{\beta}}'\mathbf{X}'\mathbf{X}\hat{\boldsymbol{\beta}} = \mathbf{y}'\mathbf{y} - 2\hat{\boldsymbol{\beta}}'\mathbf{X}'\mathbf{y} + \hat{\boldsymbol{\beta}}'\mathbf{X}'\mathbf{X}\hat{\boldsymbol{\beta}}$$

Taking the derivative and setting to zero:

$$\frac{\partial \boldsymbol{\epsilon}'\boldsymbol{\epsilon}}{\partial \hat{\boldsymbol{\beta}}} = -2\mathbf{X}'\mathbf{y} + 2\mathbf{X}'\mathbf{X}\hat{\boldsymbol{\beta}} = 0$$

$$\implies (\mathbf{X}'\mathbf{X})\hat{\boldsymbol{\beta}} = \mathbf{X}'\mathbf{y}$$

> **Key Point:** The OLS estimator for beta_1 has a structure similar to the correlation coefficient formula. Understanding the derivation process (using partial derivatives) is more valuable than simply memorizing the formulas.

---

## 7. Correlation vs. Regression

| Aspect | Correlation Analysis | Regression Analysis |
|--------|---------------------|---------------------|
| Purpose | Strength of **linearity** between two variables | **Functional relationships** between diverse variables |
| Variables | Two variables (X and Y) treated equally | Dependent vs. independent variable distinction |
| Measure | Correlation coefficient only | Linear or non-linear relationships |
| Scope | Only two variables | Simple or multiple variables |

---

## 8. Map of Analytical Methods

The appropriate analytical method depends on the outcome variable type and whether observations are independent or correlated:

| Outcome Variable | Independent Observations | Correlated Observations | Non-parametric Alternatives |
|-----------------|-------------------------|------------------------|---------------------------|
| **Continuous** (e.g., pain scale, cognitive function) | **T-test**: compares means between two independent groups | **Paired t-test**: compares means between two related groups (e.g., same subjects before and after) | **Wilcoxon sign-rank test**: non-parametric alternative to the paired t-test |
| | **ANOVA**: compares means between more than two independent groups | **Repeated-measures ANOVA**: compares changes over time in the means of two or more groups (repeated measurements) | **Wilcoxon sum-rank test** (= Mann-Whitney U test): non-parametric alternative to the t-test |
| | **Pearson's correlation coefficient** (linear correlation): shows linear correlation between two continuous variables | **Mixed models / GEE modeling**: multivariate regression techniques to compare changes over time between two or more groups; gives rate of change over time | **Kruskal-Wallis test**: non-parametric alternative to ANOVA |
| | **Linear regression**: multivariate regression technique used when the outcome is continuous; gives slopes | | **Spearman rank correlation coefficient**: non-parametric alternative to Pearson's correlation coefficient |

---

## 9. Practical Prediction Example: Diet Journey

The professor's diet journey illustrates how regression is used for real prediction:

- **Background**: 72kg in 2017, gained to 91kg in 2018, currently 81kg in 2019
- **Question**: "How many days will it take to reach a target weight of 74kg if I diet now at 81kg?"
- **Approach**: Build a regression model from past weight control records (time-series of weight measurements) and use the fitted line to predict when weight will reach the target
- **Data**: Weight measurements recorded over time from 2016 to 2019, showing the trajectory of weight changes
- **Application**: The regression line extrapolates forward from current weight (81kg) to predict when the target weight (74kg) will be reached

This example demonstrates that regression is not just abstract mathematics -- it can answer practical "when" and "how much" questions using real data.

---

## Summary

| Concept | Key Point |
|---------|-----------|
| Model | A representative (artificial) description of real phenomena |
| Deterministic model | Exact relationships, no randomness (e.g., BMI formula) |
| Probabilistic model | Deterministic component + random error (e.g., SBP = 6*age + epsilon) |
| Regression model | Relationship between dependent and explanatory variables for prediction/estimation |
| Linear regression | Y_i = beta_0 + beta_1 * X_i + epsilon_i |
| Least squares | Minimizes SSE to find optimal beta_0 and beta_1 |
| OLS formulas | beta_hat_0 = y_bar - beta_hat_1 * x_bar; beta_hat_1 = sum((x_i - x_bar)(y_i - y_bar)) / sum((x_i - x_bar)^2) |
| Correlation vs. Regression | Correlation measures linearity strength; regression analyzes functional relationships |
