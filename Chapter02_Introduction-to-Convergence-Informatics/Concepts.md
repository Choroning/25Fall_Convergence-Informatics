# Chapter 02 — Introduction to Convergence Informatics

> **Last Updated:** 2026-03-23

---

## Table of Contents

1. [What is Convergence Informatics](#1-what-is-convergence-informatics)
2. [Basic Concepts in Statistics](#2-basic-concepts-in-statistics)
3. [Data Types and Structures](#3-data-types-and-structures)
4. [Supervised vs Unsupervised Learning Overview](#4-supervised-vs-unsupervised-learning-overview)
5. [Applications of Informatics](#5-applications-of-informatics)
6. [Summary](#summary)

---

## 1. What is Convergence Informatics

### 1.1 Definition of Informatics

- **Data Science == Informatics =~ Machine Learning**
- Informatics is an area that manages, manipulates, extracts, and interprets knowledge from a tremendous amount of data (automatically or computationally)
- Data science and Informatics are a **multidisciplinary** field of study with the goal of addressing data-driven challenges

The term originates from the German word *Informatik* (Steinbuch, K. 1957), equivalent to Computer Science in English, the French *Informatique* (Philippe, 1692), and the English *Informatics* (Walter, 1967).

- Data Science principles apply to **all data — big and small**

### 1.2 Convergence (Multidisciplinary) Informatics

Convergence Informatics integrates knowledge from diverse fields to extract meaningful insights from data. It draws upon:

- Concept of Data Science
- R Programming
- Statistical Skills for Informatics
- Computational Technologies for Informatics
- Bioinformatics and Computational Biology (second-half course focus — a multidisciplinary intersection of Computer Science, Chemistry, Engineering, Mathematics, Biochemistry, Statistics, and Biology)
- Application of Informatics

### 1.3 Key Elements of Data Science

Data science involves interactions among many fields: Statistics, Pattern Recognition, Machine Learning, AI, Data Mining, Databases, Visualizations, and more. Theories and techniques from science, engineering, economics, politics, finance, and education are all brought together.

### 1.4 The Data Scientist

- **Data Scientist == Informatician** — referred to as **"The Sexiest Job of the 21st Century"**
- Data scientists are the key to realizing the opportunities presented by big data. They bring structure to data, find compelling patterns, and advise on products, processes, and decisions.

**Required skills for a Data Scientist / Informatician:**

| Category | Details |
|----------|---------|
| Mathematics | Mathematics and Applied Mathematics |
| Statistics | Statistics and Applied Statistics |
| Programming | C/C++, Java, R, Python, Julia, SQL, JavaScript |
| Data Mining | Pattern discovery and knowledge extraction |
| Database | Data Base Storage and Management |
| Machine Learning | Machine Learning and discovery |

> **Key Point:** Convergence Informatics is inherently multidisciplinary — it requires skills in mathematics, statistics, solid programming, data mining, database management, and machine learning. All disciplines interact with each other.

---

## 2. Basic Concepts in Statistics

### 2.1 Population and Sample

| Term | Definition |
|------|-----------|
| **Population** | The union of all possible events/outcomes relevant to a given topic |
| **Sample** | A subset of the population used for analysis |

### 2.2 Measures of Central Tendency

- **Average (Arithmetic Mean)**: Sum of all values divided by the number of values
- **Median**: The middle value when data is sorted in order

### 2.3 Measures of Spread

- **Range**: Difference between the maximum and minimum values

- **Variance (Population)**:

  V = sigma^2 = Sum(xi - mu)^2 / N

- **Variance (Sample)**:

  Vs = sigma_s^2 = Sum(xi - x_bar)^2 / (n - 1)

- **Standard Deviation**: The square root of variance

> **Key Point:** Sample variance divides by **(n - 1)** instead of **N** (Bessel's correction) to provide an unbiased estimate of the population variance.

### 2.4 Sampling Concepts

| Concept | Description |
|---------|-------------|
| **Representativeness** | How well a sample reflects the characteristics of the population |
| **Sampling Error** | Random variation that occurs naturally when drawing a sample |
| **Sampling Bias** | Systematic distortion that causes the sample to misrepresent the population |

> **Key Point:** Sampling error is unavoidable random variation, while sampling bias is a systematic problem in the data collection process that must be identified and corrected.

---

## 3. Data Types and Structures

### 3.1 Structured vs Unstructured Data

| Type | Description | Examples |
|------|-------------|----------|
| **Structured** | Data organized in rows and columns with a fixed schema | Databases, spreadsheets, CSV files |
| **Unstructured** | Data without a predefined data model | Emails, images, videos, web pages, sensor output |

**Structured data requirements:**
- Must have a **schema** that represents a relation with a defined number of rows and columns
- All values must be **real numbers**
- Must take the form of a **matrix**
- If data has # of rows, # of columns, schema + matrix form data + all real number values, it is structured data

Unstructured data does not reside in traditional databases, may have internal structure but does not fit a relational model, and accounts for approximately **85%** of all global data.

The systematic use of unstructured data is a central **Big Data** challenge.

### 3.2 Random Variables (R.V.)

A Random Variable is a function that maps real phenomena into data values. There are two main types:

| Type | Also Known As | Purpose | Example |
|------|---------------|---------|---------|
| **Continuous** (Numerical) | Quantitative | Calculation (quantity) | Height, weight, temperature |
| **Categorical** (Characteristic) | Qualitative | Classification (class) | Gender, color, marital status |
| **Discrete** | (subset of countable values) | Depends on context | Integer-valued counts, age in whole years |

- **Continuous attributes** have real-number values and can take infinitely many, uncountable values (represented as floating-point variables)
- **Discrete attributes** have a finite or infinite set of countable values (usually expressed as integers); binary attributes are a special form
- **Discrete vs Categorical nuance**: How you interpret integer data depends on your analysis goal:
  - **Continuous interpretation** — treat the number as a quantity for calculation (e.g., age of 22 for computing the mean or running regression)
  - **Categorical interpretation** — treat the number as a class for classification (e.g., belonging to the "20s" group for counting group frequencies or comparing characteristics between groups)
- Continuous variables can be converted to discrete variables through **binning**
- Whether a variable is continuous or categorical is determined by the **mapping process**

### 3.3 Freedom Degree Issue

Categorizing data requires **at least 3 same-value samples** to establish a meaningful category. This is related to the degrees of freedom in statistical analysis.

**Example — Age represented at different resolutions:**

| Target | Age_Cont | Age_Cate1 | Age_Cate2 |
|--------|----------|-----------|-----------|
| Student_1 | 10.41412 | 10 | 10s |
| Student_2 | 20.5213 | 20 | 20s |
| Student_3 | 22.2139123 | 22 | 20s |
| Student_4 | 23.1213 | 23 | 20s |

| | Age_Cont | Age_Cate1 | Age_Cate2 |
|---|----------|-----------|-----------|
| **Resolution** | Highest | | Lowest |
| **Type** | Continuous | Continuous / Categorical | Categorical |

- Age_Cate1 with values like (10, 10, 10, 20, 22, 23, 23, ...) is more likely to be treated as **Categorical R.V.** because some values have 3+ same-value samples
- The freedom degree requirement determines whether categorization is statistically meaningful

### 3.4 Tabulation

Tabulation is the process of converting **unstructured data into structured data** by systematically arranging classified data in rows and columns.

The tabulation process follows these steps:

1. **Experimental design** — define the research question
2. **Determination of population** — identify the target population
3. **Set variables / Get values** — define features and collect measurements
4. **Prescreening** — clean and validate the data (Data Mining)

### 3.5 Feature Extraction, Selection, and Engineering

- **Feature extraction**: Deriving meaningful variables from raw tabulated data
- **Feature selection**: Removing low-signal variables that do not contribute useful information to the analysis
- **Feature engineering**: Introducing domain-relevant, informative attributes to improve model performance

**Concrete feature extraction example** — tabulating unstructured letter sequences (AAAAA / BB / CCC / D):

| Sample | # of Alphabets | # of A | # of B | # of C | # of D |
|--------|---------------|--------|--------|--------|--------|
| S1 | 5 | 5 | 0 | 0 | 0 |
| S2 | 5 | 5 | 0 | 0 | 0 |
| S3 | 5 | 5 | 0 | 0 | 0 |
| S4 | 2 | 0 | 2 | 0 | 0 |
| S5 | 2 | 0 | 2 | 0 | 0 |
| S6 | 2 | 0 | 2 | 0 | 0 |
| S7 | 3 | 0 | 0 | 3 | 0 |
| S8 | 3 | 0 | 0 | 3 | 0 |
| S9 | 3 | 0 | 0 | 3 | 0 |
| S10 | 1 | 0 | 0 | 0 | 1 |
| S11 | 1 | 0 | 0 | 0 | 1 |
| S12 | 1 | 0 | 0 | 0 | 1 |

This technique can be applied to images, video, sequences, and other unstructured formats.

### 3.6 Types of Datasets

**Record-based data:**
- **Data matrix**: n x p matrices where n rows = objects and p columns = attributes
- **Document data**: Each document represented by a term vector (word frequency)
- **Transaction data**: Each record is a collection of items (market basket data)

**Graph-based data:**
- World wide web, molecular structures, map data

**Ordered data:**
- Spatial data, temporal data, sequential data, genetic/genomic sequence data

> **Key Point:** Structured Data = Set of Random Variables, and Data = Combination of Variables. The quality of your analysis fundamentally depends on how well you tabulate and structure your raw data.

---

## 4. Supervised vs Unsupervised Learning Overview

### 4.1 Comparison Table

| Aspect | Supervised Learning | Unsupervised Learning |
|--------|--------------------|-----------------------|
| **Answer** | Predefined answer (label) exists | No predefined answer |
| **Number of answers** | Single answer | Numerous possible answers |
| **Goal** | Prediction (find relation between Data & Class) | Pattern recognition (find data structures or hidden patterns) |
| **Example tasks** | Classification, Regression | Clustering, Association |
| **Label** | Yes | No |
| **Diverse results** | No | Yes |
| **Training data** | Labeled (input-output pairs) | Unlabeled (input only) |

**Data requirements for both SL and USL:**

| | Structured Data | Predefined Answer (= Class) |
|---|---|---|
| **Supervised** | Required | Required |
| **Unsupervised** | Required | Not required |

Both supervised and unsupervised learning require **structured data**; the difference is whether a **predefined answer (class)** exists.

### 4.2 Class (Label) in Supervised Learning

A "class" has many synonyms: **label, exact answer, ground truth, responsible variable, outcome variable, dependent variable**. Importantly, **any R.V. can be a class** — it depends on your analysis purpose.

> **Q: Does a "class" always exist in structured data?**
>
> **A:** It is determined by the **purpose of the analysis**. The existence of a class is not an intrinsic property of the data itself; it depends on what you want. When you want to predict or infer a specific variable, you designate that variable as the "class" (doing SL). When you want to discover structures or patterns without prediction, you work without a "class" (doing USL).

### 4.3 Classification and Regression (SL)

- **Classification**: Assigns new observations to predefined categories based on a training set with known labels; predicts a **categorical label** for a new piece of data
- **Regression**: Predicts a **continuous value** for a new piece of data (e.g., fitting a line through data points)

### 4.4 Clustering and Association (USL)

Unsupervised learning is often compared to the **human brain's intelligence**, with **pattern recognition** being its central mechanism. Humans naturally group and categorize the world around them — it is an innate ability. Computers, which only process 0s and 1s, need specially designed functions to replicate this.

- **Clustering (class discovery)**: Grouping objects into subsets (clusters) based on **similarity** between objects; finds and visualizes structures; used in quality control processes like outlier identification
- **Association**: Mapping relationships between different items in unlabeled data (e.g., market basket analysis — discovering which items are frequently purchased together)

> **Key Point:** Supervised learning requires labeled data and aims to predict a specific outcome (classification for categorical, regression for continuous), while unsupervised learning works with unlabeled data and aims to discover hidden patterns or groupings (clustering for groups, association for relationships).

---

## 5. Applications of Informatics

Informatics is applied in most disciplines and industries. The applications are endless, but this course focuses on the bio-medical science field, where the concept of Informatics is best established.

### 5.1 Medical Informatics

Medical informatics is the application of computers, communications, and information technology and systems to all fields of medicine — medical care, medical education, and medical research. It is a **multidisciplinary** field integrating Medicine/Biology, Mathematics, Information Systems, Computer Science, Statistics, Decision Analysis, Economics/Health Care Policy, and Psychology.

**Electronic Medical Records (EMR):**

Key benefits of EMR systems:
- **Access**: Availability, transfer, and retrieval of records
- **Legibility**: Abstraction and reporting with clear, readable data
- **Speed**: Find data **4 times faster** compared to paper records
- **Reduced data entry**: Reuse of data eliminates redundant entry
- Better organization by imposing structure
- Storage space efficiency
- Allow multiple views including aggregation
- Automated checks on data entry (spelling checks)
- Data quality and standards enforcement
- Automated decision support
- Statistics and research capabilities

**Decision Support for Diagnosis:**

Computational tools assist clinicians in diagnostic reasoning and therapeutic planning, using digital imaging, radiological information systems, and patient monitoring systems.

**Virtual Reality / Computational Simulation:**

The **da Vinci Surgical System** (Intuitive Surgical, California, USA) is a key example. The surgeon sits at a control console with 3D visualization of the surgical field and robotic surgical instruments.

### 5.2 Pharmacoinformatics

Pharmacoinformatics applies informatics principles to pharmacology. It is also a representative **multidisciplinary** field.

- **Drug discovery** and development requires the integration of multiple scientific and technological disciplines (chemistry, biology, pharmacology, pharmaceutical technology, and extensive use of information technology)
- The main idea is to integrate different informatics branches (bioinformatics, chemoinformatics, immunoinformatics, etc.) into a single platform for a seamless drug discovery process
- The first reference of the term "Pharmacoinformatics" can be found in the year **1993**
- **ASHP Statement on the Pharmacist's Role in Informatics**: "The use and integration of data, information, knowledge, technology, and automation in the medication-use process for the purpose of improving health outcomes"

**Medication Use Process Cycle:**

Selection/Reconciliation --> Ordering --> Verification/Dispensing --> Administration --> Monitoring --> Education --> (cycle repeats)

| Stage | Responsible Parties |
|-------|-------------------|
| **Medication Selection / Reconciliation** | Prescriber, nurse, pharmacist |
| **Ordering** | Prescriber, nurse, pharmacist |
| **Verification / Dispensing** | Pharmacist, technician |
| **Administration** | Nurse, caretaker, patient |
| **Monitoring** | Prescriber, nurse, pharmacist, patient, caretaker, health system |
| **Education** | Prescriber, nurse, pharmacist, patient, caretaker |

> **Key Point:** Both Medical Informatics and Pharmacoinformatics exemplify how convergence of informatics with domain-specific fields creates powerful tools for data-driven decision making, from EMR systems to automated drug discovery pipelines.

---

## Summary

| Concept | Key Point |
|---------|-----------|
| Convergence Informatics | Multidisciplinary field integrating data science, statistics, programming, and domain knowledge |
| Data Scientist | == Informatician; "Sexiest Job of the 21st Century"; requires math, stats, programming (C/C++, Java, R, Python, Julia, SQL, JavaScript), data mining, DB, ML |
| Data Science Scope | Principles apply to all data — big and small |
| Population vs Sample | Population = all possible outcomes; Sample = subset used for analysis |
| Variance | Population: divide by N; Sample: divide by (n-1) for unbiased estimation |
| Sampling | Error = random variation; Bias = systematic distortion |
| Structured Data | Schema with rows/columns, all real number values, matrix form |
| Unstructured Data | ~85% of global data; does not fit relational model; tabulation converts to structured |
| Random Variables | Continuous (numerical, for calculation) vs Categorical (characteristic, for classification); Discrete interpretation depends on analysis goal |
| Freedom Degree | Categorization requires at least 3 same-value samples; Age_Cont/Age_Cate1/Age_Cate2 resolution levels |
| Tabulation | Systematic arrangement of data in rows/columns; core step in data science pipeline |
| Feature Extraction | Derive meaningful variables from raw data (e.g., letter counting from unstructured sequences) |
| Feature Selection | Remove low-signal variables to improve analysis quality |
| Feature Engineering | Introduce domain-relevant, informative attributes |
| Supervised Learning | Labeled data, single answer, prediction goal; Classification (categorical) and Regression (continuous) |
| Unsupervised Learning | Unlabeled data, multiple answers, pattern recognition goal; Clustering (similarity grouping) and Association (item relationships) |
| Class (Label) | Any R.V. can be a class; existence depends on analysis purpose, not data itself |
| Medical Informatics | EMR (4x faster data access, reduced entry), decision support for diagnosis, da Vinci Surgical System |
| Pharmacoinformatics | Drug discovery as multidisciplinary integration; first referenced 1993; medication use process cycle |
| Bioinformatics | Second-half course focus; intersection of CS, Chemistry, Engineering, Math, Biochemistry, Stats, Biology |
