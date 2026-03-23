# Chapter 01 — R Programming Basics

> **Last Updated:** 2026-03-23

---

## Table of Contents

1. [Introduction to R](#1-introduction-to-r) -- What is R, RStudio, Console/Prompt, Good Habits, Cheatsheets, Workspace
2. [Basic Data Types](#2-basic-data-types)
3. [Variables and Assignment](#3-variables-and-assignment)
4. [Vectors and Operations](#4-vectors-and-operations)
5. [Basic Functions](#5-basic-functions)
6. [Packages](#6-packages)
7. [Summary](#summary)

---

## 1. Introduction to R

### 1.1 What is R?

R is a free, open-source programming language designed for statistical computing and data analysis. Along with Python, it is one of the two most representative languages for data science.

### 1.2 Why Use R for Data Science?

- **Free and open-source**: Available at [https://cran.r-project.org/](https://cran.r-project.org/)
- **Relatively easy** to learn for hands-on data analysis
- **Extensible**: Thousands of community-contributed packages available on CRAN
- **Strong statistical support**: Built-in functions for statistical modeling and visualization

### 1.3 RStudio (IDE for R)

RStudio is an integrated development environment (IDE) that makes programming in R easier. An IDE typically consists of a source code editor, build automation tools, and a debugger.

RStudio has four main panes:

| Pane | Purpose |
|------|---------|
| Code Editor | Write and edit R scripts |
| R Console | Execute commands interactively |
| Environment/History | View loaded variables and command history |
| Files/Plots/Packages/Help | Browse files, view plots, manage packages, access help |

### 1.4 R Console / User Prompt

- Commands are entered interactively at the R user prompt (`>`)
- **Up** and **down** arrow keys scroll through your command history
- Programming directly in the prompt window is **not recommended** -- if the system crashes or a blackout occurs, all unsaved work is lost

### 1.5 Good Programming Habits

- Always save your scripts regularly and make backups
- One of the best habits is to save every time you modify a script
- Use meaningful file naming conventions -- avoid names like `final`, `Realfinal`, `Realfinal222`

### 1.6 RStudio Cheatsheets

RStudio provides built-in reference sheets accessible via **Help > Cheatsheets**. These cover the most widely used commands and shortcuts for the IDE, data transformation, visualization, and more.

> **Tip:** Memorize the key bindings for the operations you use most frequently. This significantly speeds up your workflow.

### 1.7 R Workspace

```r
getwd()       # Check current working directory
setwd("path") # Change working directory (Warning: "\" is escape character)
```

Two options for saving your work:
1. **Save your R script** -- saves only code in text format
2. **Save your R workspace** using `save.image()` -- saves all variables in RAM

> **Key Point:** R is a **case-sensitive** language. `variableName` and `variablename` are treated as two different variables.

---

## 2. Basic Data Types

### 2.1 Core Data Types

| Type | Description | Example |
|------|-------------|---------|
| `numeric` | Real numbers (default for numbers) | `3.14`, `42` |
| `integer` | Whole numbers (append `L`) | `5L`, `100L` |
| `character` | Text strings (enclosed in quotes) | `"Hello"`, `'World'` |
| `logical` | Boolean values | `TRUE`, `FALSE` |
| `factor` | Categorical variables with levels | `factor(c("a", "b"))` |

### 2.2 Checking and Inspecting Types

```r
class(x)   # Check the data type of a variable
str(x)     # View the internal structure of an object
ls()       # List all loaded variables in the environment
```

### 2.3 Data Frames

Up to now, the variables we have defined are just single numbers. This is not very useful for storing data. The most common way of storing a dataset in R is in a **data frame**.

A data frame is a table where:
- **Rows** represent observations (individual data points)
- **Columns** represent variables (attributes measured for each observation)

Data frames are particularly useful because they can **combine different data types** (numeric, character, logical, factor) into one object. This is the key difference from matrices, which require all elements to be the same type.

```r
# Data frames vs. matrices
# - Data frames support column/row names and mixed data types (including factors)
# - Matrices require all elements to be the same type
```

> **Key Point:** Use `data()` to load built-in datasets (e.g., `data(iris)`), and use `head()`, `tail()`, `dim()`, `nrow()`, `ncol()` to quickly inspect them.

---

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

> **Key Point:** Always use `<-` for assignment in R. Reserve `=` for function arguments (e.g., `rnorm(n = 100, mean = 0)`).

---

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

> **Key Point:** R operations on vectors are **vectorized** by default -- they apply element-wise without the need for explicit loops.

---

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

- Browse available packages: [https://cran.r-project.org/web/packages/available_packages_by_name.html](https://cran.r-project.org/web/packages/available_packages_by_name.html)
- Search Google for specific functionality (e.g., "R package for boxplot")

### 6.3 Visualization with Packages

R provides basic plotting functions, but third-party packages like `ggplot2` and `ggpubr` enable more advanced and aesthetically pleasing visualizations.

```r
# Basic R visualization
hist(HeightMale)                                          # Histogram
boxplot(Height ~ Gender, data = ourData, col = c("blue", "red"))  # Boxplot

# Advanced visualization requires ggplot2 / ggpubr packages
```

> **Key Point:** One of the greatest strengths of R is its package ecosystem. You can write new functions, package them into an "R package" (or "R library"), and share them with the community via CRAN.

---

## Summary

| Concept | Key Point |
|---------|-----------|
| R & RStudio | Free, open-source language and IDE for statistical computing |
| Console / Prompt | Use arrow keys for history; avoid programming directly in prompt (risk of losing work) |
| Good habits | Save scripts regularly, make backups, use meaningful file names |
| Data types | `numeric`, `integer`, `character`, `logical`, `factor` |
| Assignment | Use `<-` (not `=`) to assign values to variables |
| Vectors | Created with `c()`; support vectorized arithmetic and indexing |
| Sequences | `seq()` for regular sequences, `rep()` for repetition, `rnorm()` for random values |
| Basic functions | `sum()`, `mean()`, `length()`, `summary()`, `head()`, `str()` |
| Packages | `install.packages()` to install, `library()` to load |
| Data frames | Table structure combining different data types; rows = observations, columns = variables |
| Visualization | Base R: `hist()`, `boxplot()`; Advanced: `ggplot2`, `ggpubr` |
