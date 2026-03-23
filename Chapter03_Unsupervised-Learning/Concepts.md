# Chapter 03 — Unsupervised Learning

> **Last Updated:** 2026-03-23

---

## Table of Contents

1. [Clustering vs. Classification](#1-clustering-vs-classification)
2. [Similarity and Distance](#2-similarity-and-distance)
3. [Distance Metrics](#3-distance-metrics)
4. [Distance Matrix, Outlier Impact, and Normalization](#4-distance-matrix-outlier-impact-and-normalization)
5. [Correlation-Based Distance](#5-correlation-based-distance)
6. [Clustering Algorithms Overview](#6-clustering-algorithms-overview)
7. [Hierarchical Clustering (HC)](#7-hierarchical-clustering-hc) *(includes worked example with all 3 linkage methods)*
8. [K-Means Clustering](#8-k-means-clustering)
9. [Summary](#summary)

---

## 1. Clustering vs. Classification

### 1.1 What is Clustering?

Clustering analysis is the process of grouping a set of objects (experimental subjects or their features) into subsets called "clusters." It is the most common form of **unsupervised learning**, which learns from raw data without predefined labels.

- Based on **similarity** between objects
- High similarity within clusters, low similarity between clusters
- Used for finding and visualizing structures, identifying outliers, and detecting global patterns of missing values

### 1.2 Clustering vs. Classification

| Aspect | Clustering | Classification |
|--------|-----------|----------------|
| Learning type | Unsupervised | Supervised |
| Classes | Unknown a priori | Predefined |
| Goal | Class discovery (identify new/unknown classes) | Class prediction (assign new cases into known classes) |
| Approach | Exploratory analysis | Find a classifier from training data |

> **Key Point:** In clustering, there can be numerous valid answers since there is no class information. The number of clusters depends on the analysis perspective and method chosen.

---

## 2. Similarity and Distance

### 2.1 Similarity Index

A numeric value that indicates how **similar** different objects are.

- Range: `0 <= Similarity <= 1`
- Higher value indicates greater similarity

### 2.2 Dissimilarity Index

A numeric value that indicates how **different** objects are.

- `Distance = 1 - Similarity = Dissimilarity`
- Higher similarity between objects leads to lower dissimilarity

> **Key Point:** The similarity measure is often more important than the clustering algorithm used. The choice of similarity/distance measure fundamentally shapes the clustering result.

---

## 3. Distance Metrics

### 3.1 Manhattan Distance (L1 Norm)

$$d_1(\mathbf{p}, \mathbf{q}) = \|\mathbf{p} - \mathbf{q}\|_1 = \sum_{i=1}^{n} |p_i - q_i|$$

**Properties:**
- Robust to outliers
- Computationally efficient
- Cannot always find the optimal solution
- Measures "city block" distance (grid-like paths)

### 3.2 Euclidean Distance (L2 Norm)

$$d_{euc}(\mathbf{x}, \mathbf{y}) = \sqrt{\sum_{i=1}^{n} (x_i - y_i)^2}$$

**Properties:**
- Can find optimal solutions via mathematical optimization
- Sensitive to outliers
- Measures straight-line distance between two points

### 3.3 L1 vs. L2 Comparison

| Property | L1 (Manhattan) | L2 (Euclidean) |
|----------|---------------|----------------|
| Outlier robustness | Robust | Sensitive |
| Computation | Efficient (computational method) | More mathematical |
| Optimal solution | Not always guaranteed | Can find optimal |
| Use case | Sparse data, robust analysis | General-purpose |

**Why L2 can find the global optimal but L1 cannot:**
- Both metrics use methods to remove signs (+/-), since distance cannot be negative. Distance range: [0, infinity).
- L2 uses squares, producing a smooth (differentiable) surface everywhere, including at the origin (0,0). This allows gradient-based optimization to find the global solution.
- L1 uses absolute values, which create a non-differentiable point at (0,0). The derivative's sign changes abruptly, so gradient-based methods cannot reliably find the global optimum.

> **Key Point:** L1-based methods are generally more robust to outliers than L2-based methods. A single outlier can significantly distort an L2-based distance matrix.

---

## 4. Distance Matrix, Outlier Impact, and Normalization

### 4.1 Distance Matrix

Given an N x P data matrix (N samples, P features):
- **Sample Distance Matrix**: N x N (distances between samples)
- **Feature Distance Matrix**: P x P (distances between features)

**Properties of a distance matrix:**
- Always a **symmetric matrix** (d(A,B) = d(B,A))
- Diagonal values are always **zero** (d(A,A) = 0)
- Distance range: **[0, infinity)**

Example with Euclidean Distance:

| | Ind1 | Ind2 | Ind3 | Ind4 |
|------|------|------|------|------|
| Ind1 | 0 | 2.828 | 3.162 | 5.099 |
| Ind2 | 2.828 | 0 | 1.414 | 3.162 |
| Ind3 | 3.162 | 1.414 | 0 | 2 |
| Ind4 | 5.099 | 3.162 | 2 | 0 |

### 4.2 Outlier Impact on Distance Matrix

A single outlier can break the entire distance matrix. This phenomenon is particularly pronounced with the L2 norm.

**Example:** 5 students with features (Age, Height, Gender). Student5 has Height = 300,000 (outlier, should be ~220).

**Without outlier** (L2 sample distance matrix):

| | St1 | St2 | St3 | St4 | St5 |
|-----|------|------|------|------|------|
| St1 | 0 | | | | |
| St2 | 1.97 | 0 | | | |
| St3 | 5.76 | 7.17 | 0 | | |
| St4 | 12.37 | 13.85 | 6.68 | 0 | |
| St5 | 50.46 | 52.09 | 44.94 | 38.31 | 0 |

**With outlier** (Student5 Height = 300,000, L2):

| | St1 | St2 | St3 | St4 | St5 |
|-----|------|------|------|------|--------|
| St1 | 0 | | | | |
| St2 | 1.97 | 0 | | | |
| St3 | 5.76 | 7.17 | 0 | | |
| St4 | 12.37 | 13.85 | 6.68 | 0 | |
| St5 | 299,829 | 299,831 | 299,824 | 299,817 | 0 |

- Distances involving St5 explode from ~50 to ~299,000
- L1 is also affected but less severely (distances still jump to ~299,818)
- This demonstrates why **outlier detection is critical before computing distance matrices**

### 4.3 Normalization (Z-scoring)

Before computing distances, features should often be normalized to ensure comparability:

- **Z-score normalization**: Subtract the mean and divide by the standard deviation, per feature
- Prevents features with larger scales from dominating the distance calculation

> **Key Point:** Without normalization, features with larger magnitudes will disproportionately influence distance calculations.

---

## 5. Correlation-Based Distance

### 5.1 Covariance

$$Cov(X, Y) = E[(X - E[X])(Y - E[Y])]$$

- Covariance is the expected product of two variables' deviations from their means, quantifying joint variability
- Covariance is **scale-dependent**: its magnitude changes if you rescale either variable
- Dividing covariance by the product of standard deviations yields **Pearson's Correlation**, which is scale-invariant

### 5.2 Pearson's Correlation

$$r_{xy} = \frac{Cov(x, y)}{\sigma_x \cdot \sigma_y} = \frac{S_{xy}}{\sqrt{S_{xx} S_{yy}}}$$

- Based on L2 Norm (mathematical method)
- Measures **linear** relationships
- Range: [-1, 1]
- Sensitive to outliers
- |r| = 1 only under perfect linear relationships

### 5.3 Spearman's Correlation

$$r_s = \rho_{\text{rg}_X, \text{rg}_Y} = \frac{\text{cov}(\text{rg}_X, \text{rg}_Y)}{\sigma_{\text{rg}_X} \cdot \sigma_{\text{rg}_Y}}$$

- Based on ranks (L1 concept, computational method)
- Captures **monotonic** relationships (not just linear, e.g., y = x^3)
- Robust to outliers (since ranks absorb extreme values)

### 5.4 Pearson vs. Spearman: Concrete Examples

**Example 1 -- Data without outliers (4 employees):**

| Employee | Hrs. Worked (Monthly) | Tasks Completed | Satisfaction |
|----------|----------------------|-----------------|--------------|
| A | 20 | 10 | 5.0 |
| B | 30 | 15 | 8.0 |
| C | 40 | 20 | 9.0 |
| D | 50 | 25 | 9.5 |

Pearson correlations:

| | HW | TC | S |
|-----|------|------|------|
| HW | 1.0 | | |
| TC | 1.0 | 1.0 | |
| S | 0.96 | 0.96 | 1.0 |

Spearman correlations:

| | HW | TC | S |
|-----|------|------|------|
| HW | 1.0 | | |
| TC | 1.0 | 1.0 | |
| S | 1.0 | 1.0 | 1.0 |

- HW-TC is perfectly linear, so both correctly measure 1.0
- HW-S is monotonic but not perfectly linear; Pearson underestimates at 0.96, while Spearman correctly captures the perfect monotonic trend as 1.0

**Example 2 -- Data with outlier (Employee D: Tasks = 5):**

| Employee | Hrs. Worked (Monthly) | Tasks Completed | Satisfaction |
|----------|----------------------|-----------------|--------------|
| A | 20 | 10 | 5.0 |
| B | 30 | 15 | 8.0 |
| C | 40 | 20 | 9.0 |
| D | 50 | **5** | 9.5 |

Pearson correlations:

| | HW | TC | S |
|-----|-------|-------|------|
| HW | 1.0 | | |
| TC | **-0.45** | 1.0 | |
| S | 0.96 | **-0.66** | 1.0 |

Spearman correlations:

| | HW | TC | S |
|-----|------|------|------|
| HW | 1.0 | | |
| TC | **0.4** | 1.0 | |
| S | 1.0 | **0.4** | 1.0 |

- The single outlier caused Pearson HW-TC to drop from **1.0 to -0.45**, completely reversing the sign and misrepresenting the underlying positive trend
- Spearman HW-TC only drops from **1.0 to 0.4**, still correctly identifying a positive relationship
- This demonstrates Pearson's extreme sensitivity to outliers vs. Spearman's robustness

### 5.5 Correlation-Based Distance Metric

$$D(X, Y) = 1 - |cor(X, Y)|$$

- Range: [0, 1]

**Why this transformation is needed:**
- Correlation range is [-1, 1], but distance range must be [0, infinity)
- Correlation can be **negative**, so it cannot be used directly as distance
- The transformation D = 1 - |cor| maps to [0, 1], which satisfies distance requirements
- **Limitation:** Directional information is lost -- you cannot determine whether the original correlation was positive or negative

**Advantage of correlation-based distance:**
- Correlation is **scale-invariant**, so no normalization is needed
- Unlike L1/L2 distances, which may require normalization that can distort the data shape, correlation works directly on the original data

### 5.6 Norm-Based vs. Correlation-Based Distance

| Property | Norm-Based (L1/L2) | Correlation-Based |
|----------|-------------------|-------------------|
| Range | [0, infinity) | [0, 1] (after transformation) |
| Measures | Magnitude difference | Pattern similarity |
| Scale sensitivity | Highly sensitive to scale and outliers | Scale-invariant |
| Normalization | Often required (can distort data) | Not required |
| Direction information | No direction concept | Lost when using absolute value |
| Usage | Absolute value differences | Trend/shape of data |
| Limitation | High scale sensitivity | May miss non-monotonic relationships |

> **Key Point:** Pearson's correlation captures linear relationships and is sensitive to outliers, while Spearman's captures monotonic relationships and is robust to outliers.

---

## 6. Clustering Algorithms Overview

### 6.1 Categories

- **Bottom-up agglomerative methods**
  - Hierarchical Clustering (HCL) (Eisen et al. 1998)

- **Top-down partitioning methods** (combinatorial optimization problem)
  - K-means (Herwig et al. 1999)
  - K-medians
  - Self-Organizing Map (SOM) (Tamayo et al. 1999)

- **Projection methods**
  - Principal Component Analysis (PCA) (Raychaudhuri et al., 2000)
  - Multi-Dimensional Scaling (MDS)

---

## 7. Hierarchical Clustering (HC)

### 7.1 Overview

HC produces a binary tree structure called a **dendrogram** that groups data at multiple levels of granularity.

- **Agglomerative** (bottom-up): Start with each object as its own cluster, merge closest pairs
- **Divisive** (top-down): Start with all objects in one cluster, split recursively
- Agglomerative is the most commonly used approach

### 7.2 HCA Four Steps

The process of performing Hierarchical Clustering Analysis can be broken down into four main steps:

1. **Create a Distance Matrix**
2. **Generate a Dendrogram** (using a linkage method)
3. **Extract Group Information from Dendrogram** (by cutting at a chosen height)
4. **Evaluate Clustering Results**

### 7.3 Agglomerative HC Algorithm

1. Let q objects form q clusters (each object is its own cluster)
2. Join two clusters that have the smallest distance (#clusters = q - 1)
3. Iterate until all clusters are connected in a hierarchical tree (Dendrogram)

### 7.4 Dendrogram Properties

- The final cluster is the **root** and each data item is a **leaf**
- The **height** of the bars indicates how close the items are
- Cut the dendrogram at a desired height to determine the number of clusters

### 7.5 Linkage Methods

The linkage method determines how distance is measured between clusters G and H:

| Linkage | Formula | Description |
|---------|---------|-------------|
| **Single** | d_S(G,H) = min d(z_i, z_j) | Minimum distance (nearest neighbor) |
| **Complete** | d_C(G,H) = max d(z_i, z_j) | Maximum distance (furthest neighbor) |
| **Average** | d_A(G,H) = (1/n_G*n_H) * sum d(z_i, z_j) | Average of all pairwise distances |

### 7.6 HC Worked Example: 6 Points (A-F) with All Three Linkage Methods

**Given:** 6 data points (A-F) in 2D space. The initial **L1 (Manhattan) distance matrix** is:

| L1 | A | B | C | D | E | F |
|----|-----|-----|-----|-----|-----|-----|
| A | 0 | | | | | |
| B | 5 | 0 | | | | |
| C | 5 | 4 | 0 | | | |
| D | 15 | 10 | 10 | 0 | | |
| E | 16 | 11 | 11 | 1 | 0 | |
| F | 19 | 14 | 14 | 4 | 3 | 0 |

The smallest distance is d(D,E) = 1, so all three methods begin by merging {D, E}.

---

#### 7.6.1 Single Linkage (Nearest Neighbor)

**Update rule:** d(merged, X) = min[d(each member, X)]

**Step 1:** Merge {D, E} (distance = 1). Update distances using min:
- d(DE, A) = min[d(D,A), d(E,A)] = min[15, 16] = 15
- d(DE, B) = min[d(D,B), d(E,B)] = min[10, 11] = 10
- d(DE, C) = min[d(D,C), d(E,C)] = min[10, 11] = 10
- d(DE, F) = min[d(D,F), d(E,F)] = min[4, 3] = 3

| Step 1 | A | B | C | DE | F |
|--------|-----|-----|-----|------|-----|
| A | 0 | | | | |
| B | 5 | 0 | | | |
| C | 5 | 4 | 0 | | |
| DE | 15 | 10 | 10 | 0 | |
| F | 19 | 14 | 14 | **3** | 0 |

**Step 2:** Merge {F, DE} (distance = 3). Update distances using min:
- d(DEF, A) = min[d(D,A), d(E,A), d(F,A)] = min[15, 16, 19] = 15
- d(DEF, B) = min[d(D,B), d(E,B), d(F,B)] = min[10, 11, 14] = 10
- d(DEF, C) = min[d(D,C), d(E,C), d(F,C)] = min[10, 11, 14] = 10

| Step 2 | A | B | C | DEF |
|--------|-----|-----|-----|------|
| A | 0 | | | |
| B | 5 | 0 | | |
| C | 5 | **4** | 0 | |
| DEF | 15 | 10 | 10 | 0 |

**Step 3:** Merge {B, C} (distance = 4).
- d(BC, A) = min[d(B,A), d(C,A)] = min[5, 5] = 5
- d(BC, DEF) = min[d(B,DEF), d(C,DEF)] = min[10, 10] = 10

| Step 3 | A | BC | DEF |
|--------|-----|------|------|
| A | 0 | | |
| BC | **5** | 0 | |
| DEF | 15 | 10 | 0 |

**Step 4:** Merge {A, BC} (distance = 5).
- d(ABC, DEF) = min[d(A,DEF), d(BC,DEF)] = min[15, 10] = 10

| Step 4 | ABC | DEF |
|--------|------|------|
| ABC | 0 | |
| DEF | **10** | 0 |

**Single Linkage merge order:** {D,E} at 1 --> {F,DE} at 3 --> {B,C} at 4 --> {A,BC} at 5 --> {ABC,DEF} at 10

---

#### 7.6.2 Complete Linkage (Furthest Neighbor)

**Update rule:** d(merged, X) = max[d(each member, X)]

**Step 1:** Merge {D, E} (distance = 1). Update distances using max:
- d(DE, A) = max[d(D,A), d(E,A)] = max[15, 16] = 16
- d(DE, B) = max[d(D,B), d(E,B)] = max[10, 11] = 11
- d(DE, C) = max[d(D,C), d(E,C)] = max[10, 11] = 11
- d(DE, F) = max[d(D,F), d(E,F)] = max[4, 3] = 4

| Step 1 | A | B | C | DE | F |
|--------|-----|-----|-----|------|-----|
| A | 0 | | | | |
| B | 5 | 0 | | | |
| C | 5 | **4** | 0 | | |
| DE | 16 | 11 | 11 | 0 | |
| F | 19 | 14 | 14 | 4 | 0 |

**Step 2:** Merge {B, C} (distance = 4, one of the minimum distances). Update distances using max:
- d(BC, A) = max[d(B,A), d(C,A)] = max[5, 5] = 5
- d(BC, DE) = max[d(B,DE), d(C,DE)] = max[11, 11] = 11
- d(BC, F) = max[d(B,F), d(C,F)] = max[14, 14] = 14

| Step 2 | A | BC | DE | F |
|--------|-----|------|------|-----|
| A | 0 | | | |
| BC | **5** | 0 | | |
| DE | 16 | 11 | 0 | |
| F | 19 | 14 | 4 | 0 |

**Step 3:** Merge {DE, F} (distance = 4).
- d(DEF, A) = max[d(DE,A), d(F,A)] = max[16, 19] = 19
- d(DEF, BC) = max[d(DE,BC), d(F,BC)] = max[11, 14] = 14

| Step 3 | A | BC | DEF |
|--------|-----|------|------|
| A | 0 | | |
| BC | 5 | 0 | |
| DEF | 19 | **14** | 0 |

**Step 4:** Merge {A, BC} (distance = 5).
- d(ABC, DEF) = max[d(A,DEF), d(BC,DEF)] = max[19, 14] = 19

| Step 4 | ABC | DEF |
|--------|------|------|
| ABC | 0 | |
| DEF | **19** | 0 |

**Complete Linkage merge order:** {D,E} at 1 --> {B,C} at 4 --> {DE,F} at 4 --> {A,BC} at 5 --> {ABC,DEF} at 19

---

#### 7.6.3 Average Linkage

**Update rule:** d(merged, X) = avg[d(each member, X)] (average of all pairwise distances)

**Step 1:** Merge {D, E} (distance = 1). Update distances using average:
- d(DE, A) = avg[d(D,A), d(E,A)] = avg[15, 16] = 15.5
- d(DE, B) = avg[d(D,B), d(E,B)] = avg[10, 11] = 10.5
- d(DE, C) = avg[d(D,C), d(E,C)] = avg[10, 11] = 10.5
- d(DE, F) = avg[d(D,F), d(E,F)] = avg[4, 3] = 3.5

| Step 1 | A | B | C | DE | F |
|--------|------|-----|-----|------|-----|
| A | 0 | | | | |
| B | 5 | 0 | | | |
| C | 5 | 4 | 0 | | |
| DE | 15.5 | 10.5 | 10.5 | 0 | |
| F | 19 | 14 | 14 | **3.5** | 0 |

**Step 2:** Merge {F, DE} (distance = 3.5). Update distances using average (now 3 members: D, E, F):
- d(DEF, A) = avg[d(D,A), d(E,A), d(F,A)] = avg[15, 16, 19] = 16.67
- d(DEF, B) = avg[d(D,B), d(E,B), d(F,B)] = avg[10, 11, 14] = 11.67
- d(DEF, C) = avg[d(D,C), d(E,C), d(F,C)] = avg[10, 11, 14] = 11.67

| Step 2 | A | B | C | DEF |
|--------|------|-----|-----|-------|
| A | 0 | | | |
| B | 5 | 0 | | |
| C | 5 | **4** | 0 | |
| DEF | 16.67 | 11.67 | 11.67 | 0 |

**Step 3:** Merge {B, C} (distance = 4).
- d(BC, A) = avg[d(B,A), d(C,A)] = avg[5, 5] = 5
- d(BC, DEF) = avg[d(B,DEF), d(C,DEF)] = avg[11.67, 11.67] = 11.67

| Step 3 | A | BC | DEF |
|--------|-----|------|-------|
| A | 0 | | |
| BC | **5** | 0 | |
| DEF | 16.67 | 11.67 | 0 |

**Step 4:** Merge {A, BC} (distance = 5).
- d(ABC, DEF) = avg of all 3x3 pairwise distances = 13.33

| Step 4 | ABC | DEF |
|--------|------|-------|
| ABC | 0 | |
| DEF | **13.33** | 0 |

**Average Linkage merge order:** {D,E} at 1 --> {F,DE} at 3.5 --> {B,C} at 4 --> {A,BC} at 5 --> {ABC,DEF} at 13.33

---

#### 7.6.4 Dendrogram Cutting Example

Using the **Average Linkage** dendrogram, cutting at **height = 8** produces two clusters:
- **Cluster 1:** {F, D, E} (merged at heights 1 and 3.5, both below 8)
- **Cluster 2:** {A, B, C} (merged at heights 4 and 5, both below 8)

The inter-cluster merge at 13.33 is above the cut line, so the two groups remain separated.

There is no single correct answer for where to cut; the choice depends on the analysis goals, though evaluation metrics can help guide the decision.

### 7.7 Cluster Labels

Cluster labels are **nominal categorical variables** with arbitrary names. The label itself carries no inherent meaning; only the grouping matters. (e.g., [A, A, B] is the same as [B, B, A])

### 7.8 Pros and Cons

| Pros | Cons |
|------|------|
| Explores all levels of granularity (1 to N clusters) | O(N^2) computational cost |
| No need to pre-specify number of clusters | Storage requirement: (N^2 - N) / 2 |
| Produces interpretable dendrogram | Sensitive to noise and outliers |

> **Key Point:** HC is ideal for exploring data structure at multiple granularity levels, but becomes computationally expensive for large datasets due to O(N^2) cost and the need to store a distance matrix of size (N^2 - N) / 2.

---

## 8. K-Means Clustering

### 8.1 Overview

K-means is a **top-down partitioning** method that divides data into K groups by minimizing within-cluster dispersion. It is a representative example of the **EM (Expectation-Maximization) algorithm**.

### 8.2 Algorithm

1. **Choose** the number of clusters K
2. **Initialize** cluster centers (centroids) randomly
3. **Assign** each data point to the nearest cluster center
4. **Update** centroids as the mean of all points in each cluster
5. **Repeat** steps 3-4 until convergence (no new re-assignments)

### 8.3 Formal Definition

Let m_k(t) = centroid of k-th cluster at step t, and C_i(t) = cluster assignment of i-th object at step t.

**Assignment step:**

$$C_i(t) = \underset{1 \leq k \leq K}{\text{argmin}} \; d(z_i, m_k(t))$$

**Convergence criterion** (total intra-cluster variance):

$$V(t) = \sum_{k=1}^{K} \sum_{i: C_i(t)=k} (z_i - m_k(t))^2$$

### 8.4 Issues and Limitations

- **Random initialization**: Different runs may produce different clusters
- **Hard assignment**: Each data point belongs to exactly one cluster
- **Shape assumption**: Implicitly assumes roughly spherical clusters
- **K must be specified**: The number of clusters must be chosen in advance
- **Local optimum**: Global optimum will not be found (converges to local minimum)
- **No within-cluster similarity information**: Unlike HC, K-means does not provide information about the internal structure of clusters

> **Key Point:** K-means is efficient for large datasets but requires pre-specifying K and may converge to different solutions depending on initialization. Use multiple random starts to mitigate this.

---

## Summary

| Concept | Key Point |
|---------|-----------|
| Clustering vs. Classification | Clustering is unsupervised (no labels); Classification is supervised (predefined labels) |
| Similarity & Distance | Distance = 1 - Similarity; choice of measure is critical; distance range [0, infinity) |
| L1 (Manhattan) | Robust to outliers, computationally efficient, non-differentiable at (0,0) |
| L2 (Euclidean) | Sensitive to outliers, can find global optimal (differentiable everywhere) |
| Distance Matrix | Symmetric matrix with zero diagonal; storage = (N^2 - N) / 2 |
| Outlier Impact | A single outlier can break L2 distances (explode to ~300K); L1 also affected |
| Covariance | Cov(X,Y) = E[(X-E[X])(Y-E[Y])]; scale-dependent, normalized = Pearson's |
| Pearson's Correlation | Measures linear relationships, sensitive to outliers (can flip sign with 1 outlier) |
| Spearman's Correlation | Measures monotonic relationships, robust to outliers (uses ranks) |
| Correlation-Based Distance | D = 1 - \|cor\|; needed because correlation [-1,1] cannot be distance directly; loses direction |
| HCA Four Steps | (1) Distance Matrix, (2) Dendrogram, (3) Extract Groups, (4) Evaluate Results |
| Hierarchical Clustering | Bottom-up agglomerative; produces dendrogram; O(N^2); storage (N^2-N)/2 |
| Linkage Methods | Single (min), Complete (max), Average (mean of all pairs); same data, different dendrograms |
| K-Means | Top-down partitioning; combinatorial optimization; requires K; sensitive to initialization |
