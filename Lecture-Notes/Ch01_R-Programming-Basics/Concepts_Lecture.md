# Chapter 1 — R Programming Basics

[Repository Guide](../../README.md) | [English](Concepts_Lecture.md) | [한국어](Concepts_Lecture.ko.md)

> **Last Updated:** 2026-10-18

> **Learning Objectives:**
> 1. Set up the R and RStudio environment and run basic commands
> 2. Understand R data types and basic data structures (vectors, factors, data frames)
> 3. Write simple R scripts with variables and expressions

---

## Table of Contents

- [1. Introduction to R](#1-introduction-to-r)
  - [1.1 What is R?](#11-what-is-r)
  - [1.2 Why Use R for Data Science?](#12-why-use-r-for-data-science)
  - [1.3 RStudio (IDE for R)](#13-rstudio-ide-for-r)
  - [1.4 R Console / User Prompt](#14-r-console--user-prompt)
  - [1.5 Good Programming Habits](#15-good-programming-habits)
  - [1.6 RStudio Cheatsheets](#16-rstudio-cheatsheets)
  - [1.7 R Workspace](#17-r-workspace)
- [2. Basic Data Types](#2-basic-data-types)
  - [2.1 Core Data Types](#21-core-data-types)
  - [2.2 Checking and Inspecting Types](#22-checking-and-inspecting-types)
  - [2.3 Data Frames](#23-data-frames)
- [3. Variables and Assignment](#3-variables-and-assignment)
  - [3.1 Assignment Operator](#31-assignment-operator)
  - [3.2 Removing Variables](#32-removing-variables)
- [4. Vectors and Operations](#4-vectors-and-operations)
  - [4.1 Creating Vectors with c()](#41-creating-vectors-with-c)
  - [4.2 Generating Sequences](#42-generating-sequences)
  - [4.3 Generating Random Values](#43-generating-random-values)
  - [4.4 Vector Indexing](#44-vector-indexing)
  - [4.5 Vector Arithmetic](#45-vector-arithmetic)
  - [4.6 Binding Vectors](#46-binding-vectors)
- [5. Basic Functions](#5-basic-functions)
  - [5.1 Output Functions](#51-output-functions)
  - [5.2 Summary Statistics](#52-summary-statistics)
  - [5.3 Data Inspection Functions](#53-data-inspection-functions)
  - [5.4 Matrix and Factor Functions](#54-matrix-and-factor-functions)
  - [5.5 Getting Help](#55-getting-help)
- [6. Packages](#6-packages)
  - [6.1 Installing and Loading Packages](#61-installing-and-loading-packages)
  - [6.2 Finding Packages](#62-finding-packages)
  - [6.3 Visualization with Packages](#63-visualization-with-packages)
- [Summary](#summary)
- [Self-Check Questions](#self-check-questions)

---

<br>

## 1. Introduction to R

### 1.1 What is R?

R is a free, open-source programming language designed for statistical computing and data analysis. Along with Python, it is one of the two most representative languages for data science.

### 1.2 Why Use R for Data Science?

- **Free and open-source:** It can be downloaded from [https://cran.r-project.org/](https://cran.r-project.org/).
- Hands-on data analysis is **relatively easy** to learn in R.
- **Extensible:** Thousands of community-contributed packages are available on CRAN.
- **Strong statistical support:** It provides built-in functions for statistical modeling and visualization.

### 1.3 RStudio (IDE for R)

RStudio is an integrated development environment (IDE) that makes programming in R easier. An IDE typically consists of a source code editor, build automation tools, and a debugger.

RStudio has four main panes. In the default layout, the code editor is at the top left, the R console at the bottom left, the environment and history at the top right, and the files, plots, packages, and help pane at the bottom right.

```text
┌──────────────────────┬────────────────────────────┐
│ Code Editor          │ Environment / History      │
│                      │                            │
├──────────────────────┼────────────────────────────┤
│ R Console            │ Files / Plots /            │
│                      │ Packages / Help            │
└──────────────────────┴────────────────────────────┘
```

*Figure 1. Default pane layout of RStudio*

| Pane | Purpose |
|------|---------|
| Code Editor | Write and edit R scripts |
| R Console | Execute commands interactively |
| Environment/History | View loaded variables and command history |
| Files/Plots/Packages/Help | Browse files, view plots, manage packages, access help |

*Table 1. Main panes of RStudio and their purposes*

### 1.4 R Console / User Prompt

- Commands are entered interactively at the R user prompt (`>`).
- The **up** and **down** arrow keys scroll through the command history.
- Programming directly in the prompt window is **not recommended**, because all unsaved work is lost if the system crashes or a blackout occurs.

### 1.5 Good Programming Habits

- Always save your scripts regularly and make backups.
- One of the best habits is to save every time you modify a script.
- Use meaningful file naming conventions and avoid names like `final`, `Realfinal`, and `Realfinal222`.

### 1.6 RStudio Cheatsheets

RStudio provides built-in reference sheets accessible via **Help > Cheatsheets**. These cover the most widely used commands and shortcuts for the IDE, data transformation, visualization, and more.

> **Note:** **Tip.** Memorizing the key bindings for the operations you use most frequently significantly speeds up your workflow.

### 1.7 R Workspace

```r
getwd()       # Check current working directory
setwd("path") # Change working directory (Warning: "\" is escape character)
```

`getwd()` returns the current working directory, and `setwd()` changes it. Because `\` is the escape character in R strings, Windows paths must be separated with `/` or `\\`, as in `"C:/data"` or `"C:\\data"`.

There are two ways to save your work.
1. **Save your R script:** This saves only the code in text format.
2. **Save your R workspace:** `save.image()` saves all variables of the workspace held in memory (RAM) to an `.RData` file.

> **Key Point:** R is a **case-sensitive** language. `variableName` and `variablename` are treated as two different variables.

---

<br>

## 2. Basic Data Types

### 2.1 Core Data Types

| Type | Description | Example |
|------|-------------|---------|
| `numeric` | Real numbers (default for numbers) | `3.14`, `42` |
| `integer` | Whole numbers (append `L`) | `5L`, `100L` |
| `character` | Text strings (enclosed in quotes) | `"Hello"`, `'World'` |
| `logical` | Boolean values | `TRUE`, `FALSE` |
| `factor` | Categorical variables with levels | `factor(c("a", "b"))` |

*Table 2. Core data types of R*

Strictly speaking, `factor` is not a basic type but an object that attaches level information to integer codes. Therefore `class()` returns `"factor"`, while `typeof()` returns `"integer"`.

### 2.2 Checking and Inspecting Types

```r
class(x)   # Check the data type of a variable
str(x)     # View the internal structure of an object
ls()       # List all loaded variables in the environment
```

### 2.3 Data Frames

A variable that holds a single number is not very useful for storing data. The most common way of storing a dataset in R is in a **data frame**.

A data frame is a table where:
- **Rows** represent observations (individual data points).
- **Columns** represent variables (attributes measured for each observation).

Data frames are particularly useful because they can **combine different data types** (numeric, character, logical, factor) into one object. Each column can have a different type, while the values within one column share a type. This is the key difference from matrices, which require all elements to be the same type.

```r
# Data frames vs. matrices
# - Data frames support column/row names and mixed data types (including factors)
# - Matrices require all elements to be the same type
```

> **Key Point:** Use `data()` to load built-in datasets (e.g., `data(iris)`), and use `head()`, `tail()`, `dim()`, `nrow()`, `ncol()` to quickly inspect them.

---

<br>

## 3. Variables and Assignment

### 3.1 Assignment Operator

```r
x <- 10           # Preferred assignment operator
y <- "Hello"       # Assign a character string
z <- TRUE          # Assign a logical value
```

While `=` can also be used for assignment, `<-` is **highly recommended** to avoid confusion with the equality operator `==`.

### 3.2 Removing Variables

```r
rm(x)              # Remove a single variable
rm(list = ls())    # Remove all variables from the environment
```

> **Key Point:** Always use `<-` for assignment in R, and use `=` for specifying function arguments (e.g., `rnorm(n = 100, mean = 0)`).

---

<br>

## 4. Vectors and Operations

### 4.1 Creating Vectors with c()

Vectors are the most basic data structure in R. The `c()` function combines values into a vector.

```r
numericVector   <- c(1, 2, 3, 4, 5)
characterVector <- c("One", "Two", "Three", "Four", "Five")
logicalVector   <- c(TRUE, TRUE, FALSE, FALSE, FALSE)
```

### 4.2 Generating Sequences

```r
# Using the colon operator
1:10                              # 1, 2, 3, ..., 10

# Using seq()
seq(from = 1, to = 10)            # Same as 1:10
seq(from = 1, to = 10, by = 2)    # 1, 3, 5, 7, 9
seq(1, 10, length = 5)            # 5 evenly spaced values

# Using rep()
rep(1, 3)                         # 1, 1, 1
rep(c("a", "b"), 5)               # "a","b","a","b",...
rep(1:3, each = 10)               # 1,1,...,2,2,...,3,3,...
```

### 4.3 Generating Random Values

```r
rnorm(n = 100, mean = 180, sd = 1)  # 100 random values from N(180, 1)
```

### 4.4 Vector Indexing

```r
x <- c(10, 20, 30, 40, 50)
x[1]          # First element: 10
x[c(1, 3)]   # First and third elements: 10, 30
x[-2]         # All except the second: 10, 30, 40, 50
```

Indices in R start at 1, and a negative index excludes the element at that position.

### 4.5 Vector Arithmetic

```r
a <- c(1, 2, 3)
b <- c(4, 5, 6)

a + b    # Element-wise addition: 5, 7, 9
a * b    # Element-wise multiplication: 4, 10, 18
a > 2    # Element-wise comparison: FALSE, FALSE, TRUE
```

### 4.6 Binding Vectors

```r
cbind(a, b)   # Combine column-wise (side by side)
rbind(a, b)   # Combine row-wise (stacked)
```

When `a` and `b` have length 3, `cbind(a, b)` creates a matrix with 3 rows and 2 columns, and `rbind(a, b)` creates a matrix with 2 rows and 3 columns.

> **Key Point:** Arithmetic operators, comparison operators, and many built-in functions in R are **vectorized** by default: they apply element-wise without the need for explicit loops.

---

<br>

## 5. Basic Functions

### 5.1 Output Functions

```r
print("Hello World")     # Formatted output of a single object
cat("Value:", x, "\n")   # Concatenated plain-text output
```

### 5.2 Summary Statistics

```r
sum(1:100)       # Sum: 5050
mean(x)          # Arithmetic mean
median(x)        # Median
sd(x)            # Standard deviation
length(x)        # Number of elements
min(x)           # Minimum value
max(x)           # Maximum value
summary(x)       # Min, Q1, Median, Mean, Q3, Max
```

### 5.3 Data Inspection Functions

```r
head(iris)          # First 6 rows (default)
tail(iris)          # Last 6 rows (default)
head(iris, n = 10)  # First 10 rows
dim(iris)           # Dimensions (rows, columns)
nrow(iris)          # Number of rows
ncol(iris)          # Number of columns
fix(iris)           # Open data in spreadsheet-like editor
```

### 5.4 Matrix and Factor Functions

```r
# Create a matrix
A <- matrix(NA, nrow = 10, ncol = 5)

# Create a factor variable
B <- factor(c("a", "b", "a", "b"))
levels(B)     # View factor levels
```

### 5.5 Getting Help

```r
help(sum)      # Open help page for a function
?sum           # Shortcut for help()
help.start()   # Open R's HTML help system in a browser
```

> **Key Point:** Use `summary()` on numeric variables to get descriptive statistics, and on factor variables to get frequency counts. The behavior adapts to the variable type.

---

<br>

## 6. Packages

### 6.1 Installing and Loading Packages

```r
# Set repository for downloading packages
setRepositories()

# Install a package from CRAN
install.packages("ggplot2")

# Load a package into the current session
library(ggplot2)
```

### 6.2 Finding Packages

- Available packages can be browsed in the CRAN list at [https://cran.r-project.org/web/packages/available_packages_by_name.html](https://cran.r-project.org/web/packages/available_packages_by_name.html).
- For specific functionality, search Google (e.g., "R package for boxplot").

### 6.3 Visualization with Packages

R provides basic plotting functions, but third-party packages like `ggplot2` and `ggpubr` enable more advanced and aesthetically pleasing visualizations.

```r
# Basic R visualization
hist(HeightMale)                                          # Histogram
boxplot(Height ~ Gender, data = ourData, col = c("blue", "red"))  # Boxplot

# Advanced visualization requires ggplot2 / ggpubr packages
```

> **Key Point:** One of the greatest strengths of R is its package ecosystem. You can write new functions, bundle them into an **R package**, and share them with the community via CRAN. Packages are often called R libraries, but strictly speaking, a library in R is a directory where packages are installed.

---

<br>

## Summary

| Concept | Key Summary |
|---------|-------------|
| R and RStudio | R is a free, open-source language for statistical computing, and RStudio is an IDE for R. |
| Console and prompt | The arrow keys browse the command history, and programming directly in the prompt risks losing work. |
| Good habits | Save scripts regularly, make backups, and use meaningful file names. |
| Data types | The core data types are `numeric`, `integer`, `character`, `logical`, and `factor`. |
| Assignment | Use `<-` (not `=`) to assign values to variables. |
| Vectors | Vectors are created with `c()` and support vectorized arithmetic and indexing. |
| Sequences | `seq()` generates regular sequences, `rep()` generates repetitions, and `rnorm()` generates normally distributed random values. |
| Basic functions | Frequently used basic functions include `sum()`, `mean()`, `length()`, `summary()`, `head()`, and `str()`. |
| Packages | Packages are installed with `install.packages()` and loaded with `library()`. |
| Data frames | A data frame is a table structure combining different data types, with rows as observations and columns as variables. |
| Visualization | Base R provides `hist()` and `boxplot()`, and advanced visualization uses `ggplot2` and `ggpubr`. |

---

<br>

## Self-Check Questions

1. **Vector indexing:** For `x <- c(10, 20, 30, 40, 50)`, write the results of `x[c(2, 5)]` and `x[-c(1, 2)]`.

   <details>
   <summary>Answer</summary>

   Indices in R start at 1, so `x[c(2, 5)]` gives the second and fifth elements, 20 and 50. A negative index excludes the element at that position, so `x[-c(1, 2)]` gives 30, 40, 50, without the first and second elements.

   </details>

2. **Generating sequences:** Write the results of `seq(1, 10, by = 3)`, `rep(c(1, 2), each = 2)`, and `seq(1, 10, length = 5)`.

   <details>
   <summary>Answer</summary>

   `seq(1, 10, by = 3)` starts at 1 and adds 3 while staying at most 10, giving 1, 4, 7, 10. `rep(c(1, 2), each = 2)` repeats each element twice, giving 1, 1, 2, 2. `seq(1, 10, length = 5)` gives 5 evenly spaced values between 1 and 10; the step is (10 - 1) / 4 = 2.25, so the result is 1.00, 3.25, 5.50, 7.75, 10.00.

   </details>

3. **Vector arithmetic:** For `a <- c(1, 2, 3)` and `b <- c(4, 5, 6)`, write the results of `b - a`, `a * 2`, and `sum(a * b)`.

   <details>
   <summary>Answer</summary>

   The operations apply element-wise, so `b - a` is 3, 3, 3. In `a * 2`, every element is multiplied by 2, giving 2, 4, 6. `a * b` is 4, 10, 18, so `sum(a * b)` is 4 + 10 + 18 = 32.

   </details>

4. **Data frames and matrices:** You want to store students' heights (numeric) and genders (categorical) in one object. Which is suitable, a matrix or a data frame? Give the reason.

   <details>
   <summary>Answer</summary>

   A data frame is suitable. A matrix requires all elements to be the same type, so putting heights and genders together turns the heights into characters as well. For example, `cbind(c(170, 160), c("M", "F"))` becomes a character matrix with the elements `"170"`, `"160"`, `"M"`, `"F"`. A data frame can have a different type in each column, so heights can be stored as numeric and genders as a factor.

   </details>
