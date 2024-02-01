# Load data:
fact <- read.csv("D:\\APTECH\\0_Do_an\\N4\\Phase 4_Datawarehose\\Tien - Final\\weather.csv")
head(fact)
colnames(fact)

# Select columns excluding those with "quality" in the name
library(dplyr)
selected_columns <- fact %>%
  select(-contains("quality"))
# View the resulting data frame
head(selected_columns)
colnames(selected_columns)

# Exclude some text columns while preserving ID columns:
# Columns to be deselected
columns_to_exclude <- c("weather_ID","station_ID","time_ID","fact_ID","wind.type", "precipitationEstimatedObservation.discrepancy")

# Deselect specified columns
newcolumns <- fact %>%
  select(-one_of(columns_to_exclude))

# View the resulting
colnames(newcolumns)

# Evaluate cluster division - determine the optimal number of clusters:
install.packages("factoextra")
library(cluster)
library(factoextra)
fviz_nbclust(newcolumns[, 1:8], kmeans, method = "wss") # Choose either 2 or 3 clusters. Prefer 3 clusters because one cluster may represent missing values.

# Visualize 3 clusters:
library(ggplot2)
cluster <- kmeans(newcolumns[, 1:10], 3)
cluster$cluster <- as.factor(cluster$cluster)
ggplot(newcolumns, aes(airTemperature.value, dewPoint.value_old, colour = cluster$cluster)) + geom_point()

# Identify the list of data rows belonging to each cluster:
df_clusters <- data.frame(StationID = fact$station_ID, Cluster = cluster$cluster)
df_clusters
# Merge df_clusters with fact:
newdf1 <- cbind(fact, df_clusters)
head(newdf1)

# The following commands transform data into a matrix:
any(is.na(newcolumns[, 3:13])) # False: no null values
any(is.infinite(newcolumns[, 3:13]))
# Check the class of the columns
class(newcolumns[, 3:13])
# Convert columns to a numeric matrix
newcolumns[, 3:13] <- as.matrix(newcolumns[, 3:13])
# Check for infinite values
any(is.infinite(newcolumns[, 3:13]))

###-----------------------------------------------USE CLUSTER PARTICIPATION ANALYSIS (CPA)-------------
install.packages(c("FactoMineR", "factoextra"))
library("FactoMineR")
library("factoextra")

# Print a preview of the data:
head(newcolumns)
dim(newcolumns)
# Only take numeric columns: OK
# Run PCA function:
pca <- PCA(newcolumns, graph = FALSE)
print(pca)
# Variance of the dataset:
eig.val <- get_eigenvalue(pca)
eig.val # The result suggests that climate partitioning should be based on all 10 factors.
# Plot:
fviz_eig(pca, addlabels = TRUE, ylim = c(0, 100), ncp = 10)
#----------
# PCA separation:
myPr <- prcomp(newcolumns, scale = TRUE) # PC1 is dim 1, PC2 is dim 2...
myPr

# View myPr:
myPr$x # From 4 columns initially, it transforms to PC1...PC4 in the new space.
# Combine these 4 columns:
newdf1 <- cbind(fact, myPr$x) 
head(newdf1)

# Scatter plot of PC1, PC2 with classification by temperature: Unable to run because there is no classification column
fviz_pca_ind(pca,
             geom.ind = "point", # show points only (not "text")
             col.ind = newdf1$Cluster, # color by groups
             palette = c("#00AFBB", "#E7B800", "#FC4E07"),
             addEllipses = TRUE, # Concentration ellipses
             legend.title = "Groups"
)

# The plot shows 3 climate zones. Perhaps, it's better to divide into 2 clusters only.
# Export the file newdf1, taking the Cluster column as the classification.
# Assuming 'your_dataframe' is the name of your dataframe
write.csv(newdf1, "D:\\APTECH\\0_Do_an\\N4\\Phase 4_Datawarehose\\Trang - DW\\newdf1.csv", row.names = FALSE)

##-------------------Classify smaller clusters from Cluster------------------
# Split newdf1 into 3 smaller dataframes based on each Cluster:
cluster1 <- subset(newdf1, Cluster == 1)
head(cluster1)
# Exclude unnecessary columns:
cluster2 <- subset(newdf1, Cluster == 2)
cluster3 <- subset(newdf1, Cluster == 3)
# Cluster each dataframe separately:
# cluster1:
# Columns to be deselected
columns_to_exclude <- c("station_ID","time_ID","fact_ID","wind.type", "visibility.variability.value", "skyCondition.cavok", "skyCondition.ceilingHeight.determination")
# Deselect specified columns
newcluster1 <- cluster1 %>%
  select(-one_of(columns_to_exclude))
# Select columns excluding those with "quality" in the name
new1 <- newcluster1 %>%
  select(-contains("quality"))
head(new1)
colnames(new1)
# Evaluate cluster division - determine the optimal number of clusters:
install.packages("factoextra")
library(cluster)
library(factoextra)
fviz_nbclust(new1[, 1:10], kmeans, method = "wss") # Choose separately the column containing numbers
# Result: 2 clusters
# Visualize 2 clusters by temperature and dew point:
library(ggplot2)
cluster1 <- kmeans(new1[, 1:10], 2)
ggplot(new1, aes(airTemperature.value, dewPoint.value_old, colour = cluster1$cluster)) + geom_point() 
# Identify which cluster each data row belongs to:
head(new1)
clusterlist1 <- data.frame(StationIDlist = new1$StationID, Cluster1 = cluster1$cluster)
clusterlist1
# Merge new1 with clusterlist1:
newlist1 <- cbind(new1, clusterlist1)
head(newlist1)
# Comment: After clustering based on 10 characteristics, it is not possible to divide further based on those 10 characteristics.
# You may want to reconsider classification based on coordinates.
