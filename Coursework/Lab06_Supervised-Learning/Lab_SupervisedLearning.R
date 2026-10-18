# @file    Lab_SupervisedLearning.R
# @brief   Supervised learning methods including decision tree classification,
#          cross-validated model comparison (LDA, QDA, SVM), and custom
#          k-nearest neighbors implementation
# @author  Cheolwon Park
# @date    2025-12-03


# =============================================================================
# 0. PACKAGE SETUP
# =============================================================================

## Set Environment
setRepositories(ind = c(1:8))

# install.packages("caret")
# install.packages("rpart.plot")
# install.packages("kknn")
# install.packages("igraph")

library(tidyverse)
library(datarium)   # for data
library(ggplot2)
library(caret)      # for cross-validation algorithms
library(dplyr)
library(rpart)
library(rpart.plot)
library(kknn)


# =============================================================================
# 1. DECISION TREE CLASSIFICATION (TITANIC DATA)
# =============================================================================

# Step1: Loading data (Titanic data)
data <- read.csv("https://raw.githubusercontent.com/guru99-edu/R-Programming/master/titanic_data.csv")

dim(data)
head(data)
tail(data)

shuffleIndex <- sample(1:nrow(data))
data <- data[shuffleIndex, ]
head(data)

data$age <- as.numeric(data$age)
data$fare <- as.numeric(data$fare)

# Step2 : Data Cleansing
# Drop variables home.dest, cabin, name, X and ticket
# Create factor variables for pclass and survived
# Drop the NA values

cleanData <- data %>%
  select(-c(home.dest, cabin, name, x, ticket)) %>%
  mutate(pclass = factor(pclass, levels = c(1, 2, 3), labels = c('Upper', 'Middle', 'Lower')),
         survived = factor(survived, levels = c(0, 1), labels = c('No', 'Yes')),
         sex = factor(sex),
         embarked = factor(embarked)) %>%
  na.omit()

glimpse(cleanData)


## Generating function
create_train_test <- function(data, size = 0.8, train = TRUE) {
  n_row <- nrow(data)
  total_row <- size * n_row
  train_sample <- 1:total_row
  if (train == TRUE) {
    return (data[train_sample, ])
  } else {
    return (data[-train_sample, ])
  }
}

dataTrain <- create_train_test(cleanData, 0.5, train = TRUE)
dataTest <- create_train_test(cleanData, 0.5, train = FALSE)

dim(dataTrain)
dim(dataTest)

prop.table(table(dataTrain$survived))
prop.table(table(dataTest$survived))

# Modeling
model <- rpart(survived~., data = dataTrain, method = 'class')

# Visualization for decision tree model
rpart.plot(model, extra = 106)

# Model Eval.
predictResult <- predict(model, dataTest, type = 'class')

confusion <- table(dataTest$survived, predictResult)
confusion

sum(diag(confusion)) / sum(confusion) * 100


# =============================================================================
# 2. CROSS-VALIDATED MODEL COMPARISON (BREAST CANCER DATA)
# =============================================================================

## By using Caret package

## Data Loading & Cleansing (Step 1)
webAddress <- "http://archive.ics.uci.edu/ml/machine-learning-databases/breast-cancer-wisconsin/wdbc.data"

Data <- read.csv(webAddress, head = F, stringsAsFactors = T)

features <- c("radius", "texture", "perimeter", "area", "smoothness", "compactness",
              "convavity", "concave_points", "symmetry", "fractal_dimension")

colnames(Data) <- c("id", "diagnosis", paste0(features, "_mean"), paste0(features, "_se"), paste0(features, "_worst"))

View(Data)

cleanData <- Data[,3:ncol(Data)]
rownames(cleanData) <- Data$id
View(cleanData)

cleanData <- cbind(cleanData, Data$diagnosis)
cleanData <- data.frame(cleanData[,1:10],
                        Diagnosis = cleanData[,ncol(cleanData)])

# Raw Data shuffling
randomIdx <- sample(1:nrow(cleanData))
cleanData <- cleanData[randomIdx,]
dim(cleanData)


### Define training control (Step 2)
trainControl <- trainControl(method = "cv", number = 10)

### Modeling Building & Model Estimation (Step 3)
# LDA model
model_lda <- train(Diagnosis~., data = cleanData, method = "lda", trControl = trainControl)

model_lda
names(model_lda)
model_lda$results

# QDA model
model_qda <- train(Diagnosis~., data = cleanData, method = "qda", trControl = trainControl)
model_qda$results

# SVM model (Linearity assumption)
model_svmLine <- train(Diagnosis~., data = cleanData, method = "svmLinear", trControl = trainControl)
model_svmLine$results

# SVM model (RBF kernel assumption)
model_svmRadial <- train(Diagnosis~., data = cleanData, method = "svmRadial", trControl = trainControl)
model_svmRadial$results


## Application of Prediction Model for new subjects
newData <- cleanData[1:10,-ncol(cleanData)]

predict(model_svmRadial, newdata = newData)


# =============================================================================
# 3. CUSTOM K-NEAREST NEIGHBORS IMPLEMENTATION
# =============================================================================

## Euclidean distance
euclidean_distance <- function(x1, x2) {
  sqrt(sum((x1 - x2)^2))
}

# Custom KNN
knn_classify_CI <- function(train_X, train_y, test_X, k = 3) {
  predictions <- c()

  for (i in 1:nrow(test_X)) {
    test_point <- test_X[i, ]
    distances <- apply(train_X, 1, function(row) euclidean_distance(row, test_point))
    k_idx <- order(distances)[1:k]
    k_labels <- train_y[k_idx]
    prediction <- names(sort(table(k_labels), decreasing = TRUE))[1]

    predictions <- c(predictions, prediction)
  }

  return(predictions)
}


## Usage in data
data(iris)

set.seed(42)
idx <- sample(1:nrow(iris), 100)
train <- iris[idx, ]
test  <- iris[-idx, ]

train_X <- train[, 1:4]
train_y <- train[, 5]

test_X  <- test[, 1:4]
test_y  <- test[, 5]

pred <- knn_classify_CI(train_X, train_y, test_X, k = 5)

table(pred, test_y)
