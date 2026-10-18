# @file    Lab_LinearRegression.R
# @brief   Linear regression modeling on diet data with visualization using
#          ggplot2 and diagnostic plots
# @author  Cheolwon Park
# @date    2025-11-19


# =============================================================================
# 0. PACKAGE SETUP
# =============================================================================

## Set Environment
setRepositories(ind = 1:7)

## Load library
library(data.table)
library(ggplot2)


# =============================================================================
# 1. LINEAR REGRESSION WITH DIET DATA
# =============================================================================

## Load data
data <- data.frame(fread("../data/DietData_v1.csv"))
# View(data)

dim(data)
head(data)
str(data)
class(data)

## Modeling
plot(lm(Kg~Diet.day, data = data))

## Visualization with data & fitted plot
ggplot(data, aes(y = Kg, x = Diet.day)) +
  geom_point() +
  stat_smooth(method = "loess") +
  theme_classic()
