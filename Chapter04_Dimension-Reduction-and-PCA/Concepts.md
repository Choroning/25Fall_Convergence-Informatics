# Chapter 04 — Dimension Reduction and PCA

> **Last Updated:** 2026-03-23

---

## Table of Contents

1. [Dimensionality Reduction](#1-dimensionality-reduction)
2. [Feature Selection vs. Dimensionality Reduction](#2-feature-selection-vs-dimensionality-reduction)
3. [Two Main Approaches](#3-two-main-approaches)
4. [Linear Algebra Prerequisites](#4-linear-algebra-prerequisites)
5. [Principal Component Analysis (PCA)](#5-principal-component-analysis-pca)
6. [PCA Theory and Derivation](#6-pca-theory-and-derivation)
7. [Geometric Rationale of PCA](#7-geometric-rationale-of-pca)
8. [Mean, Variance, and Covariance](#8-mean-variance-and-covariance)
9. [Other Dimensionality Reduction Methods](#9-other-dimensionality-reduction-methods)
10. [Practical Considerations](#10-practical-considerations)
11. [Summary](#summary)

---

## 1. Dimensionality Reduction

### 1.1 Definition

Dimensionality reduction is the process of selecting the most relevant features from thousands or millions of low-level features to build **better**, **faster**, and **easier to understand** learning models.

### 1.2 Why Dimensionality Reduction?

- **Speed up training algorithms**: In high dimensions, non-critical variables can lead to poor performance or the amount of data to process becomes extremely large
- **Simpler and more stable models**: Models trained with too many dimensions are easy to overfit; reducing dimensions makes them more robust
- **Better visualization**: Lower dimensions make it easier to visualize data structures

### 1.3 Curse of Dimensionality

As the number of dimensions increases, the space grows exponentially and the density of the same amount of data becomes sparse:

| Dimensions | Space | Data Points | Density |
|-----------|-------|-------------|---------|
| 1 | 10 | 8 | 80% |
| 2 | 100 | 8 | 8% |
| 3 | 1000 | 8 | 0.8% |

### 1.4 Applications

Dimensionality reduction is widely used in:
- Bioinformatics
- Machine vision
- Text categorization
- Market analysis
- Quality control
- OCR / Handwriting recognition

> **Key Point:** Occam's Razor applies — "When faced with two equally good hypotheses, always choose the simpler." Reducing dimensions often leads to simpler, more generalizable models.

---

## 2. Feature Selection vs. Dimensionality Reduction

### 2.1 Feature Selection

- New features are a **subset** of the original features
- Only a small number of features need to be computed for classification
- Preserves interpretability of original features

### 2.2 Dimensionality Reduction (Feature Extraction)

- New features are **combinations** (linear for PCA/LDA) of the original features
- Creates synthetic, composite variables
- Harder to interpret, but can capture more information in fewer dimensions

> **Key Point:** Feature selection keeps original features (interpretable). Dimensionality reduction creates new combined features (more compact but less interpretable).

---

## 3. Two Main Approaches

### 3.1 Projection

Project high-dimensional data onto a lower-dimensional subspace while preserving as much information as possible. For example, projecting 3D data onto a 2D plane.

### 3.2 Manifold Learning

- A **manifold** is a subspace that encompasses high-dimensional data
- **Manifold learning** discovers the intrinsically low-dimensional structure in high-dimensional data
- Steps: (1) Represent data structure as a graph, (2) Compute low-dimensional embedding, (3) Apply ML

**Motivating Examples:**

- **Swiss roll**: Data lies on a 2D surface rolled into 3D. Points A1 and A2 may be far apart in Euclidean distance (straight-line through the roll), but close along the manifold surface. Euclidean distance in the ambient space fails to capture true proximity on the manifold.
- **Golf swing**: Sequential frames of a golf swing form a manifold in high-dimensional pixel space. Using Euclidean distance, the nearest neighbors to a given frame may include visually dissimilar poses. After discovering the manifold, semantically close data (temporally adjacent swing positions) are correctly identified as neighbors.

### 3.3 Classification of Methods

```
Dimensionality Reduction
├── Linear
│   └── PCA
└── Non-linear
    ├── Preserve global structure
    │   ├── MDS
    │   └── t-SNE
    └── Preserve local structure
        └── UMAP
```

> **Key Point:** Linear methods like PCA work well when the data lies near a linear subspace. Non-linear methods (MDS, t-SNE, UMAP) capture more complex structures.

---

## 4. Linear Algebra Prerequisites

### 4.1 Vectors

- Data can be described with vectors (perspectives from physics, computer science, and mathematics)
- **Constant multiplier of vector**: scaling a vector by a scalar
- **Sum of vectors**: adding two vectors component-wise
- **Row vector vs. column vector**: matrix multiplication follows from the dot product of row and column vectors

### 4.2 Linear Combination

A linear combination combines constant multipliers and sums of vectors — it describes a vector by combining two (or more) characteristics at once.

### 4.3 Linear Transformation

- A function between two vector spaces that **preserves linear combinations**
- **A matrix IS a linear transformation**: applying a matrix A to a vector x produces another vector Ax
- Eigenvectors and eigenvalues arise from this: Ax = lambda * x means the matrix only scales (by lambda) along the eigenvector direction

### 4.4 Connection to PCA

When data is represented in a high-dimensional vector space, the covariance matrix acts as a linear transformation. Finding its eigenvectors reveals the directions in which the data is most spread out (principal components).

---

## 5. Principal Component Analysis (PCA)

### 5.1 Overview

PCA is probably the most widely-used and well-known of the "standard" multivariate methods. It was invented by Pearson (1901) and Hotelling (1933), and first applied in ecology by Goodall (1954) under the name "factor analysis."

PCA takes a data matrix of n objects by p variables, which may be correlated, and **summarizes it by uncorrelated axes (principal components)** that are linear combinations of the original p variables.

### 5.2 Goal of PCA

Find the smallest subspace of the high-dimensional space that keeps the most information about the original data.

- Summarize data with many (p) variables by a smaller set of (k) derived variables
- **The first k components** display as much as possible of the variation among objects
- Balance between clarity of representation and oversimplification (loss of information)
- "Residual" variation = information not retained in the reduced representation

### 5.3 PCA Projects Data

PCA maintains the structure of the original data and reduces dimensions by projecting data onto vectors. It projects data first to the axis with the **largest variance**.

> **Key Point:** PCA is only affected by covariance matrices. It finds the directions of maximum variance in the data and projects the data onto those directions.

---

## 6. PCA Theory and Derivation

### 6.1 Mathematical Setup

Let **X** = [x_1, ..., x_m] be an N x m data matrix (N dimensions, m instances).

Let **U** be an N x N orthogonal matrix, where **UU^T = I_N**.

- Transform: **y = Ux**
- Inverse: **x = U^T y**
- Approximation using M basis vectors (M <= N): **x_hat = sum(u_i * y_i) for i=1 to M**

### 6.2 Reconstruction Error

$$\varepsilon^2 = \mathbb{E}\{\|\mathbf{x} - \hat{\mathbf{x}}\|^2\} = \frac{1}{m} \sum_{j=1}^{m} \|\mathbf{x}_j - \hat{\mathbf{x}}_j\|$$

**Goal:** Minimize the reconstruction error:

$$\arg \min_{\mathbf{U}} \varepsilon^2, \quad \text{s.t.} \quad \mathbf{U}^T \mathbf{U} = \mathbf{I}_N$$

### 6.3 Derivation via Lagrange Multipliers

The error can be expressed as:

$$\varepsilon^2 = \sum_{i=M+1}^{N} \mathbf{u}_i^T \boldsymbol{\Sigma} \mathbf{u}_i$$

where **Sigma** is the covariance matrix (since **x** is centered: E{xx^T} = Sigma).

Using Lagrange multipliers for the orthogonality constraint:

$$L = \sum_{i=M+1}^{N} \mathbf{u}_i^T \boldsymbol{\Sigma} \mathbf{u}_i - \sum_{i=M+1}^{N} \lambda_i(\mathbf{u}_i^T \mathbf{u}_i - 1)$$

Setting the derivative to zero:

$$\frac{\partial L}{\partial \mathbf{u}_i} = 2\boldsymbol{\Sigma}\mathbf{u}_i - 2\lambda_i\mathbf{u}_i = 0 \implies \boldsymbol{\Sigma}\mathbf{u}_i = \lambda_i\mathbf{u}_i$$

### 6.4 Eigenvalue Interpretation

The equation **Sigma * u_i = lambda_i * u_i** shows that:
- **u_i** are **eigenvectors** of the covariance matrix Sigma
- **lambda_i** are the corresponding **eigenvalues**

The reconstruction error becomes:

$$\varepsilon^2 = \sum_{i=M+1}^{N} \lambda_i$$

The error is **minimal** when lambda_{M+1}, ..., lambda_N are the **smallest** eigenvalues. This means we keep the eigenvectors corresponding to the **largest** eigenvalues as our principal components.

### 6.5 Computing the Covariance Matrix

$$\boldsymbol{\Sigma} = \frac{1}{n} \mathbf{X}^T \mathbf{X}$$

where **X** is the mean-centered data matrix. The (i,j) entry of X^T X is the dot product of the i-th and j-th feature columns.

### 6.6 Covariance Matrix Geometric Interpretation

For a 2D covariance matrix:

$$\boldsymbol{\Sigma} = \begin{bmatrix} \sigma_x^2 & \text{Cov}(X,Y) \\ \text{Cov}(X,Y) & \sigma_y^2 \end{bmatrix}$$

- **Diagonal entries** (sigma_x^2, sigma_y^2): the **spread (variance) along each axis** — how much data stretches along X and Y independently
- **Off-diagonal entries** (Cov(X,Y)): the **joint spread** between variables — how X and Y move together

**Why X^T X captures covariance:**

X^T X produces a **matrix of dot products between feature columns**. Each entry dot(X_i, X_j) measures how aligned feature i and feature j are across all observations. Dividing by n normalizes this into the covariance. This is why Sigma = (1/n) X^T X when X is mean-centered.

When the covariance matrix is used as a linear transformation on data, it stretches data along the directions of greatest variance. The eigenvectors of this transformation reveal those directions (principal components), and the eigenvalues reveal how much stretching occurs (amount of variance).

> **Key Point:** The principal components are the eigenvectors of the covariance matrix, ordered by eigenvalue magnitude. The eigenvalues represent the amount of variance explained by each component.

---

## 7. Geometric Rationale of PCA

### 7.1 Geometric View

- Objects are represented as a cloud of n points in a multidimensional space with an axis for each of the p variables
- The **centroid** of the points is defined by the mean of each variable
- The **variance** of each variable is the average squared deviation of its n values around the mean

$$V_i = \frac{1}{n-1} \sum_{m=1}^{n} (X_{im} - \bar{X}_i)^2$$

### 7.2 Eigenvalues and Eigenvectors in Covariance Matrix

| | Original Meaning | Meaning in Covariance Matrix |
|---|---|---|
| **Eigenvectors** | Express the direction of the main axis in which the matrix acts on the vector | Express the direction in which the data is distributed |
| **Eigenvalues** | Size of eigenvectors | Size of increasing vector space (amount of variance) |

### 7.3 Toy Example (2x2 Matrix)

For A = [[4, 2], [3, 5]]:

1. Solve the characteristic equation: det(A - lambda*I) = 0
2. (lambda - 7)(lambda - 2) = 0, so lambda = 7, 2
3. For lambda = 7: eigenvector = c * (2, 3)
4. For lambda = 2: eigenvector = c * (-1, 1)

> **Key Point:** Eigenvalues determine how much variance is captured along each eigenvector direction. Larger eigenvalues correspond to more important principal components.

---

## 8. Mean, Variance, and Covariance

### 8.1 Mean (Expectation)

|  | Discrete (PMF) | Continuous (PDF) |
|--|----------------|-----------------|
| **Formula** | E(x) = sum(p_i * x_i) | E(x) = integral(x * f(x) dx) |

### 8.2 Variance

|  | Discrete (PMF) | Continuous (PDF) |
|--|----------------|-----------------|
| **Formula** | V(X) = sum((x_i - m)^2 * p_i) = E(X^2) - m^2 | Var[X] = integral((x - E[X])^2 * f(x) dx) = E[X^2] - E[X]^2 |

Standard deviation: sigma(X) = sqrt(V(X))

### 8.3 Covariance

For random variables X and Y with E(X) = mu, E(Y) = nu:

$$\text{Cov}(X, Y) = E((X - \mu)(Y - \nu)) = E(XY) - \mu\nu = E(XY) - E(X)E(Y)$$

**If X and Y are independent**, then E(XY) = E(X)E(Y) = mu * nu, so **Cov(X, Y) = 0**.

This is why PCA creates **uncorrelated** principal components: the eigenvectors of the covariance matrix define new axes along which the covariance between any two components is zero.

### 8.4 Correlation

Because covariance is affected by the absolute scale of variables, we normalize:

$$\rho = \frac{\text{Cov}(X, Y)}{\sqrt{\text{Var}(X) \cdot \text{Var}(Y)}}, \quad -1 \leq \rho \leq 1$$

---

## 9. Other Dimensionality Reduction Methods

### 9.1 MDS (Multi-Dimensional Scaling)

- **Non-linear** method that preserves **global structure**
- Attempts to preserve pairwise distances between data points in the lower-dimensional space
- Two variants: **Metric MDS** (= Principal Coordinate Analysis, PCoA) and **Non-Metric MDS**
- **PCA vs. PCoA**: PCA reduces dimensions based on "covariance", while PCoA (Metric MDS) reduces dimensions based on "distance"
- When using Euclidean distance, PCoA (MDS) and PCA produce **the same** dimensionally reduced result (clustering with minimized distance = clustering by maximized correlation)
- Distance metrics include: (1) **Euclidean distance** (Pythagorean theorem), (2) **Absolute value of log fold change** (uses log to make asymmetric differences symmetric, then averages absolute values across samples)

### 9.2 t-SNE (t-distributed Stochastic Neighbor Embedding)

- **Non-linear** vector visualization algorithm that preserves **global structure**
- Performs dimensionality reduction while preserving **similarity** between points in high dimensions and embedding space
- **Why not just project?** Simple projection to 1D can destroy cluster separation (e.g., two well-separated clusters in 2D may overlap when projected onto a single axis)

**Algorithm outline:**

1. For each interest point x_i, compute distances to all other points x_j
2. Divide by perplexity sigma_i (a parameter that adds stability; each point has a different value)
3. Apply the negative exponential function to get conditional probability p_{j|i} (closer points get higher probability)
4. Symmetrize: p_ij = (p_{j|i} + p_{i|j}) / 2n
5. In the embedding space, compute similarity q_ij using **t-distribution** (not Gaussian): q_ij = (1 + |y_i - y_j|^2)^{-1} / sum
6. Minimize the KL-divergence between p_ij and q_ij by adjusting embedding positions

**Why t-distribution?** The t-distribution has heavier tails than the normal distribution, meaning it is more widely distributed from the mean. This gives distant points more room to spread out in the embedding, improving cluster separation.

**Key property:** Results change every run because the movement positions of data change each time it is calculated. Useful for visualization but not deterministic.

### 9.3 UMAP (Uniform Manifold Approximation and Projection)

- **Non-linear** method that preserves **local structure**
- Based on **topological data analysis** and **manifold learning**
- Uses concepts from topology: simplices (0-simplex = point, 1-simplex = edge, 2-simplex = triangle, 3-simplex = tetrahedron), simplicial complexes, and the nerve theorem
- Covers data with circles of varying radius and builds simplicial complexes to capture the important topology of the data

**UMAP vs. t-SNE:**

| UMAP | t-SNE |
|------|-------|
| No limit to the size of the embedding dimension | Embedding is only possible in two or three dimensions |
| Better preserves **the local neighbor graph** structure | Better preserves the **overall** structure |
| **Faster** than t-SNE | Time is determined by a hyperparameter called perplexity |

### 9.4 Comparison

| Method | Type | Preserves | Speed | Use Case |
|--------|------|-----------|-------|----------|
| PCA | Linear | Global variance | Fast | General reduction, preprocessing |
| MDS | Non-linear | Global distances | Moderate | When distance matrix is available |
| t-SNE | Non-linear | Global structure | Slow | Visualization of clusters |
| UMAP | Non-linear | Local structure | Fast | Visualization, preserving topology |

> **Key Point:** PCA is best for linear data and preprocessing. For visualization of high-dimensional data with complex structures, t-SNE and UMAP are preferred.

---

## 10. Practical Considerations

### 10.1 Scree Plot

A scree plot displays eigenvalues (or explained variance ratio) in descending order. It helps determine the number of components to retain:
- Look for an "elbow" where the curve flattens
- Components before the elbow capture the most meaningful variance

**Connection to eigenvalue decomposition:** The values plotted on a scree plot **are** the eigenvalues from the PCA eigenvalue decomposition (Sigma * u_i = lambda_i * u_i). Each eigenvalue lambda_i represents the variance captured by the i-th principal component. The scree plot simply arranges these eigenvalues in descending order to visualize the diminishing returns of adding more components.

### 10.2 Explained Variance Ratio

The proportion of total variance explained by the k-th component:

$$\text{Explained Variance Ratio}_k = \frac{\lambda_k}{\sum_{i=1}^{N} \lambda_i}$$

A common rule of thumb is to retain enough components to explain 80-95% of the total variance.

### 10.3 When to Use What

| Scenario | Recommended Method |
|----------|--------------------|
| Linear relationships, preprocessing | PCA |
| Need interpretable features | Feature Selection |
| 2D/3D visualization of clusters | t-SNE or UMAP |
| Preserve pairwise distances | MDS |
| Large dataset, fast visualization | UMAP |

> **Key Point:** Always center (and often scale) the data before applying PCA. The choice between methods depends on whether the data structure is linear or non-linear and whether the goal is analysis or visualization.

---

## Summary

| Concept | Key Point |
|---------|-----------|
| Dimensionality Reduction | Reduce features to build better, faster, simpler models |
| Curse of Dimensionality | Data density decreases exponentially as dimensions increase |
| Feature Selection vs. Extraction | Selection keeps original features; extraction creates new combinations |
| PCA | Linear method; finds eigenvectors of covariance matrix as principal components |
| Covariance Matrix | Sigma = (1/n) X^T X; encodes variance and co-variance between features |
| Eigenvalues | Represent the amount of variance captured by each principal component |
| Eigenvectors | Define the direction of each principal component |
| Reconstruction Error | Minimized by keeping components with the largest eigenvalues |
| t-SNE | Non-linear; excellent for visualization; preserves global structure |
| UMAP | Non-linear; fast; preserves local structure |
| MDS | Non-linear; preserves pairwise distances |
| Scree Plot | Used to determine the optimal number of components to retain |
