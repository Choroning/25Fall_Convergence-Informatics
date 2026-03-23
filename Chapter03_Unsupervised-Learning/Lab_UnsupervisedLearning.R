# @file    Lab_UnsupervisedLearning.R
# @brief   Unsupervised learning methods including hierarchical clustering,
#          k-means clustering with silhouette analysis, PCA, t-SNE, and UMAP
#          for dimensionality reduction and visualization
# @author  Cheolwon Park
# @date    2025-11-12


# =============================================================================
# 0. PACKAGE SETUP
# =============================================================================

## Set Environment
setRepositories(ind = 1:7)

## Install packages
# install.packages("preprocessCore")
# install.packages("plotly")
# install.packages("tsne")
# install.packages("umap")
# install.packages("factoextra")

## Load library
library(cluster)
library(preprocessCore)
library(plotly)
library(stats)
library(tsne)
library(ggplot2)
library(umap)
library(data.table)
library(dplyr)
library(factoextra)


# =============================================================================
# 1. HIERARCHICAL CLUSTERING WITH USArrests DATA
# =============================================================================

## Load data
data(USArrests)

# dim(USArrests)
# str(USArrests)
# tail(USArrests)
# head(USArrests)

## Step 1.5 ****** Normalization
data <- scale(USArrests)
data <- data.frame(data)

str(data)
head(data)

data <- data[,-3]
head(data)

# boxplot(USArrests)
# boxplot(data)

## Step 2: Get distance matrix
d1_euclidean <- dist(data, method = "euclidean")
# d2_euclidean <- dist(t(data))

# View(as.matrix(d1))
# View(as.matrix(d2))

## Step 3: Do clustering
HCL_complete_ED <- hclust(d1_euclidean, method = "complete")

## Step 4: Drawing dendrogram
plot(HCL_complete_ED)

## Final step: Generate cluster information
Group <- as.factor(cutree(HCL_complete_ED, k = 2))
class(Group)

## Factor analysis
boxplot(data$Murder~Group)
boxplot(data$Assault~Group)
boxplot(data$Rape~Group)

# Group[which(Group == 1)]
# Group[which(Group == 2)]


# =============================================================================
# 2. HIERARCHICAL CLUSTERING WITH ELITE SPORTS CARS DATA (VARIABLES)
# =============================================================================

data <- data.frame(fread("Elite Sports Cars in Data.csv"))

# View(data)

##
newID <- paste0(data$Brand, "_", data$Model)
length(newID)

data <- data[,-c(1,2)]

dim(data)
str(data)

summary(factor(data$Safety_Rating))
summary(factor(data$Production_Units))

numeric_data <- data %>% select(where(is.numeric))
str(numeric_data)
dim(numeric_data)

numeric_data <- numeric_data %>% select(-c("Safety_Rating", "Production_Units"))
dim(numeric_data)
## Numeric RV selection

## Step2: scale
data <- data.frame(scale(numeric_data))

# pdf("test.pdf", width = 20, height = 4)
#   boxplot(as.matrix(data))
# dev.off()

## Step3: Get dist matrix
d_euclidean <- dist(t(data), method = "euclidean")
d_manhattan <- dist(t(data), method = "manhattan")

dim(as.matrix(d_euclidean))
dim(as.matrix(d_manhattan))

## Step4: Do clustering
HCL_Ecl_AVG <- hclust(d_euclidean, method = "average")
HCL_Man_AVG <- hclust(d_manhattan, method = "average")

## Visualization for dendrogram
plot(HCL_Ecl_AVG)
plot(HCL_Man_AVG)

## To generate group information
grp <- cutree(HCL_Man_AVG, k = 2)
grp <- factor(grp)

View(data.frame(newID, grp))

## Factor analysis
plot(data$Safety_Rating~data$Production_Units)

boxplot(data$Year~grp)
boxplot(data$Country~grp)
boxplot(data$Condition~grp)
boxplot(data$Engine_Size~grp)
boxplot(data$Horsepower~grp)
boxplot(data$Torque~grp)
boxplot(data$Weight~grp)
boxplot(data$Top_Speed~grp)
boxplot(data$Acceleration_0_100~grp)
boxplot(data$Fuel_Type~grp)

table(data$Condition, grp)
prop.table(table(df$Category1, df$Category2), margin = 1)  # row-wise proportions


# =============================================================================
# 3. HIERARCHICAL CLUSTERING WITH ELITE SPORTS CARS DATA (INDIVIDUALS)
# =============================================================================

data <- data.frame(fread("Elite Sports Cars in Data.csv"))

##
newID <- paste0(data$Brand, "_", data$Model)
length(newID)

data <- data[,-c(1,2)]

numeric_data <- data %>% select(where(is.numeric))
str(numeric_data)
dim(numeric_data)

numeric_data <- numeric_data %>% select(-c("Safety_Rating", "Production_Units"))
dim(numeric_data)

numeric_data <- scale(numeric_data)

## Step3: Get dist matrix
d_euclidean <- dist(numeric_data, method = "euclidean")
d_manhattan <- dist(numeric_data, method = "manhattan")

dim(as.matrix(d_euclidean))
dim(as.matrix(d_manhattan))

## Step4: Do clustering
HCL_Ecl_AVG <- hclust(d_euclidean, method = "average")
HCL_Man_AVG <- hclust(d_manhattan, method = "average")

## Visualization for dendrogram
plot(HCL_Ecl_AVG)
plot(HCL_Man_AVG)


# =============================================================================
# 4. K-MEANS CLUSTERING WITH SILHOUETTE ANALYSIS
# =============================================================================

## Perform K-means clustering
outputKmeans <- list()

for(i in 2:10){
  outputKmeans[[i]] <- kmeans(numeric_data, centers = i)
}

outputKmeans[[1]]   ## NA
outputKmeans[[2]]   ## k == 2
outputKmeans[[3]]   ## k == 3
##...##
outputKmeans[[10]]  ## k == 10

names(outputKmeans[[2]])

outputKmeans[[2]]$cluster

## Silhouette score for each k
sil_k_2_10 <- c()

for(i in 2:10){
  temp <- silhouette(outputKmeans[[i]]$cluster,
                     d_euclidean)

  sil_k_2_10[i] <- mean(data.frame(temp)[,3])
}

tempOutput <- data.frame(sil_k_2_10, 1:10)
colnames(tempOutput) <- c("Sil.", "k")

tempOutput


# =============================================================================
# 5. PCA AND CLUSTER COMPARISON WITH USArrests DATA
# =============================================================================

data(USArrests)
data <- USArrests
class(data)

## Step 1
PCA_USAreests <- prcomp(USArrests, scale = TRUE)
names(PCA_USAreests)

## Eigen value => Explanability transpose
sum((PCA_USAreests$sdev / sum(PCA_USAreests$sdev))[1:2])

## Final outcome (We will not employ)
plot(PCA_USAreests$x[,1:2])

head(USArrests)

##
kmean_3 <- kmeans(data, 3)

HCL_Ecl_AVG <- hclust(dist(data, method = "euclidean"), method = "average")

## PCA plot with k-means (k=3 param)
fviz_cluster(list(data = data, cluster = kmean_3$cluster))

## PCA plot with HCL
fviz_cluster(list(data = data, cluster = cutree(HCL_Ecl_AVG, k = 3)))

table(data.frame(Kmeans_3 = factor(kmean_3$cluster),
                   HCL = factor(cutree(HCL_Ecl_AVG, k = 3))))

## Silhouette score (Scree plot)
fviz_nbclust(data, FUN = hcut, method = "silhouette", cex=2)


# =============================================================================
# 6. DIMENSIONALITY REDUCTION: t-SNE, UMAP, AND PCA ON IRIS DATA
# =============================================================================

## Iris data
data(iris)
data <- iris

species <- iris$Species
class(species)

data <- iris[,1:4]

## Do tSNE
tsne <- tsne(data, initial_dims = 2)
tsne

tsne <- data.frame(tsne)

## Do UMAP
outcomeUmap <- umap(data, n_components = 2, random_state = 15)
names(outcomeUmap)

Umap <- outcomeUmap[["layout"]]
Umap <- data.frame(Umap)

## Do PCA
Pca <- prcomp(data)$x
Pca <- data.frame(Pca[,1:2])

## Drawing PCA plot with two dimensional vectors by PCA
ggplot(Pca, aes(x = PC1, y = PC2, color = species)) +
  geom_point(size = 3.5) +
  theme_classic()

## Drawing tSNE plot with two dimensional vectors
ggplot(tsne, aes(x = X1, y = X2, color = species)) +
  geom_point(size = 3.5) +
  theme_classic()

## Drawing UMAP plot with two dimensional vectors by UMAP
ggplot(Umap, aes(x = X1, y = X2, color = species)) +
  geom_point(size = 3.5) +
  theme_classic()
