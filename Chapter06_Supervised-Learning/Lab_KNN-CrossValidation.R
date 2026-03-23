# @file    Lab_KNN-CrossValidation.R
# @brief   KNN classification from scratch with stratified K-fold
#          cross-validation, including custom euclidean distance,
#          majority-vote KNN classifier, and fold-wise accuracy evaluation
# @author  Cheolwon Park
# @date    2025-12-03


# =============================================================================
# 1. EUCLIDEAN DISTANCE FUNCTION
# =============================================================================

euclidean_distance <- function(x1, x2) {
  sqrt(sum((x1 - x2)^2))
}


# =============================================================================
# 2. KNN CLASSIFICATION FROM SCRATCH
#    train_X : training features (matrix/data.frame)
#    train_y : training labels (vector, factor recommended)
#    test_X  : test features
#    k       : number of neighbors
# =============================================================================

knn_classify <- function(train_X, train_y, test_X, k = 3) {
  train_y <- as.factor(train_y)
  n_test  <- nrow(test_X)
  predictions <- character(n_test)

  for (i in seq_len(n_test)) {
    test_point <- test_X[i, ]

    # Compute distance to all training samples
    distances <- apply(train_X, 1, function(row) euclidean_distance(row, test_point))

    # Get indices of k nearest neighbors
    k_idx <- order(distances)[1:k]

    # Get labels of k nearest neighbors
    k_labels <- train_y[k_idx]

    # Majority vote (most frequent label)
    pred_label <- names(sort(table(k_labels), decreasing = TRUE))[1]

    predictions[i] <- pred_label
  }

  return(factor(predictions, levels = levels(train_y)))
}


# =============================================================================
# 3. STRATIFIED K-FOLD GENERATION
#    y    : label vector (factor recommended)
#    K    : number of folds
#    seed : seed for reproducibility
#    Returns: list of length K, each element is a test index vector
# =============================================================================

create_folds <- function(y, K = 5, seed = 42) {
  set.seed(seed)
  y <- as.factor(y)
  folds <- vector("list", K)

  classes <- levels(y)

  for (cls in classes) {
    idx <- which(y == cls)
    idx <- sample(idx)  # shuffle

    # Split idx into K segments
    fold_ids <- cut(seq_along(idx), breaks = K, labels = FALSE)

    for (f in seq_len(K)) {
      folds[[f]] <- c(folds[[f]], idx[fold_ids == f])
    }
  }

  return(folds)
}


# =============================================================================
# 4. KNN K-FOLD CROSS-VALIDATION
#    X           : feature matrix/data.frame
#    y           : label vector
#    k_neighbors : KNN k parameter
#    K           : number of folds
#    seed        : seed for fold consistency
#    Returns: list (fold accuracies, mean accuracy, standard deviation)
# =============================================================================

knn_cv <- function(X, y, k_neighbors = 5, K = 5, seed = 42) {
  X <- as.matrix(X)
  y <- as.factor(y)

  folds <- create_folds(y, K = K, seed = seed)
  acc   <- numeric(K)

  for (i in seq_len(K)) {
    test_idx  <- folds[[i]]
    train_idx <- setdiff(seq_len(nrow(X)), test_idx)

    train_X <- X[train_idx, , drop = FALSE]
    train_y <- y[train_idx]
    test_X  <- X[test_idx, , drop = FALSE]
    test_y  <- y[test_idx]

    pred <- knn_classify(train_X, train_y, test_X, k = k_neighbors)

    acc[i] <- mean(pred == test_y)
  }

  return(list(
    fold_accuracies = acc,
    mean_accuracy   = mean(acc),
    sd_accuracy     = sd(acc)
  ))
}


# =============================================================================
# 5. EXAMPLE: IRIS DATA WITH 5-FOLD CROSS-VALIDATION
# =============================================================================

set.seed(42)

X <- iris[, 1:4]
y <- iris$Species

# K=5-fold, k=5 neighbors KNN cross-validation
cv_result <- knn_cv(X, y, k_neighbors = 5, K = 5, seed = 42)

cv_result$fold_accuracies   # accuracy per fold
cv_result$mean_accuracy     # mean accuracy
cv_result$sd_accuracy       # standard deviation
