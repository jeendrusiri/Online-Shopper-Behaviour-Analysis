
# ============================================================
# CASE STUDY: ONLINE SHOPPER BEHAVIOUR ANALYSIS
# AND PURCHASE PREDICTION USING R
# ============================================================

# Step 1: Load required packages

library(dplyr)
library(ggplot2)

# Step 2: Read the dataset

data <- read.csv(choose.files())

# Step 3: Inspect the dataset

head(data)
dim(data)
str(data)
summary(data)

# Step 4: Check missing values

colSums(is.na(data))

# Step 5: Count duplicate rows

sum(duplicated(data))

# Step 6: Inspect duplicate rows

duplicate_rows <- data[duplicated(data), ]

head(duplicate_rows)
nrow(duplicate_rows)
table(duplicate_rows$Revenue)

# Step 7: Inspect numerical variables

summary(data[, sapply(data, is.numeric)])

range(data$BounceRates)
range(data$ExitRates)
range(data$PageValues)

# Step 8: Convert categorical variables to factors

data$OperatingSystems <- as.factor(data$OperatingSystems)
data$Browser <- as.factor(data$Browser)
data$Region <- as.factor(data$Region)
data$TrafficType <- as.factor(data$TrafficType)
data$Month <- as.factor(data$Month)
data$VisitorType <- as.factor(data$VisitorType)
data$Weekend <- as.factor(data$Weekend)
data$Revenue <- as.factor(data$Revenue)

# Verify data types

str(data)


# ============================================================
# STEP 9: PURCHASE VS NON-PURCHASE SESSIONS
# ============================================================

ggplot(data, aes(x = Revenue, fill = Revenue)) +
  geom_bar() +
  labs(
    title = "Purchase vs Non-Purchase Sessions",
    x = "Purchase Outcome",
    y = "Number of Sessions",
    fill = "Revenue"
  ) +
  theme_minimal()


# ============================================================
# STEP 10A: BOUNCE RATE BY PURCHASE OUTCOME
# ============================================================

ggplot(data, aes(x = Revenue, y = BounceRates, fill = Revenue)) +
  geom_boxplot() +
  labs(
    title = "Bounce Rate by Purchase Outcome",
    x = "Purchase Outcome",
    y = "Bounce Rate"
  ) +
  theme_minimal()


# ============================================================
# STEP 10B: EXIT RATE BY PURCHASE OUTCOME
# ============================================================

ggplot(data, aes(x = Revenue, y = ExitRates, fill = Revenue)) +
  geom_boxplot() +
  labs(
    title = "Exit Rate by Purchase Outcome",
    x = "Purchase Outcome",
    y = "Exit Rate"
  ) +
  theme_minimal()


# ============================================================
# STEP 10C: MONTHLY PURCHASE RATE (ADDED GRAPH)
# ============================================================

monthly_summary <- aggregate(
  I(Revenue == "TRUE") ~ Month,
  data = data,
  FUN = mean
)

names(monthly_summary) <- c("Month", "Purchase_Rate")

# Order months according to their observed purchase rate
monthly_summary <- monthly_summary[
  order(monthly_summary$Purchase_Rate, decreasing = TRUE),
]

print(monthly_summary)

ggplot(
  monthly_summary,
  aes(x = reorder(Month, Purchase_Rate), y = Purchase_Rate)
) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Purchase Rate by Month",
    x = "Month",
    y = "Purchase Rate"
  ) +
  theme_minimal()


# ============================================================
# STEP 10D: CORRELATION HEATMAP (ADDED GRAPH)
# ============================================================

numeric_data <- data[, sapply(data, is.numeric)]

correlation_matrix <- cor(
  numeric_data,
  use = "complete.obs"
)

correlation_data <- as.data.frame(
  as.table(correlation_matrix)
)

names(correlation_data) <- c(
  "Variable1", "Variable2", "Correlation"
)

ggplot(
  correlation_data,
  aes(x = Variable1, y = Variable2, fill = Correlation)
) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(Correlation, 2)), size = 2.5) +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = 0,
    limits = c(-1, 1)
  ) +
  labs(
    title = "Correlation Heatmap of Numerical Variables",
    x = "Variables",
    y = "Variables",
    fill = "Correlation"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(
      angle = 45, hjust = 1, size = 7
    ),
    axis.text.y = element_text(size = 7)
  )


# ============================================================
# STEP 11: SPLIT DATA INTO TRAINING AND TESTING SETS
# ============================================================

set.seed(123)

train_index <- sample(
  seq_len(nrow(data)),
  size = floor(0.8 * nrow(data))
)

train_data <- data[train_index, ]
test_data <- data[-train_index, ]

cat("Training sessions:", nrow(train_data), "\n")
cat("Testing sessions:", nrow(test_data), "\n")


# ============================================================
# STEP 12: TRAIN LOGISTIC REGRESSION MODEL
# ============================================================

model <- glm(
  Revenue ~ Administrative +
    Administrative_Duration +
    Informational +
    Informational_Duration +
    ProductRelated +
    ProductRelated_Duration +
    BounceRates +
    ExitRates +
    PageValues +
    SpecialDay +
    Month +
    VisitorType +
    Weekend,
  data = train_data,
  family = binomial
)

summary(model)


# ============================================================
# STEP 13: PREDICT ON TEST DATA
# ============================================================

probabilities <- predict(
  model,
  newdata = test_data,
  type = "response"
)

# Predictions at the standard 0.50 threshold

predictions <- ifelse(
  probabilities >= 0.50,
  "TRUE",
  "FALSE"
)

head(predictions, 10)


# ============================================================
# STEP 13A: PREDICTED PROBABILITY HISTOGRAM (ADDED GRAPH)
# ============================================================

probability_data <- data.frame(
  Predicted_Probability = probabilities,
  Actual_Revenue = test_data$Revenue
)

ggplot(
  probability_data,
  aes(x = Predicted_Probability, fill = Actual_Revenue)
) +
  geom_histogram(
    bins = 30,
    position = "identity",
    alpha = 0.55
  ) +
  labs(
    title = "Predicted Purchase Probabilities",
    x = "Predicted Probability of Purchase",
    y = "Number of Sessions",
    fill = "Actual Purchase"
  ) +
  theme_minimal()


# ============================================================
# STEP 14: EVALUATE MODEL AT THRESHOLD 0.50
# ============================================================

predicted_class <- factor(
  predictions,
  levels = c("FALSE", "TRUE")
)

actual_class <- factor(
  test_data$Revenue,
  levels = c("FALSE", "TRUE")
)

confusion_matrix <- table(
  Actual = actual_class,
  Predicted = predicted_class
)

print(confusion_matrix)

TN <- confusion_matrix["FALSE", "FALSE"]
FP <- confusion_matrix["FALSE", "TRUE"]
FN <- confusion_matrix["TRUE", "FALSE"]
TP <- confusion_matrix["TRUE", "TRUE"]

accuracy <- (TP + TN) / sum(confusion_matrix)

precision <- ifelse(
  TP + FP == 0, 0, TP / (TP + FP)
)

recall <- ifelse(
  TP + FN == 0, 0, TP / (TP + FN)
)

f1_score <- ifelse(
  precision + recall == 0,
  0,
  2 * precision * recall / (precision + recall)
)

cat("\n--- Results at Threshold 0.50 ---\n")
cat("Accuracy:", round(accuracy * 100, 2), "%\n")
cat("Precision:", round(precision * 100, 2), "%\n")
cat("Recall:", round(recall * 100, 2), "%\n")
cat("F1-score:", round(f1_score * 100, 2), "%\n")


# ============================================================
# STEP 15: EVALUATE A LOWER THRESHOLD OF 0.30
# NOTE: EXPLORATORY TEST-SET COMPARISON
# ============================================================

predictions_30 <- ifelse(
  probabilities >= 0.30,
  "TRUE",
  "FALSE"
)

cm_30 <- table(
  Actual = factor(
    test_data$Revenue,
    levels = c("FALSE", "TRUE")
  ),
  Predicted = factor(
    predictions_30,
    levels = c("FALSE", "TRUE")
  )
)

print(cm_30)

TN_30 <- cm_30["FALSE", "FALSE"]
FP_30 <- cm_30["FALSE", "TRUE"]
FN_30 <- cm_30["TRUE", "FALSE"]
TP_30 <- cm_30["TRUE", "TRUE"]

accuracy_30 <- (TP_30 + TN_30) / sum(cm_30)

precision_30 <- ifelse(
  TP_30 + FP_30 == 0,
  0,
  TP_30 / (TP_30 + FP_30)
)

recall_30 <- ifelse(
  TP_30 + FN_30 == 0,
  0,
  TP_30 / (TP_30 + FN_30)
)

f1_30 <- ifelse(
  precision_30 + recall_30 == 0,
  0,
  2 * precision_30 * recall_30 /
    (precision_30 + recall_30)
)

results <- data.frame(
  Metric = c("Accuracy", "Precision", "Recall", "F1-score"),
  Value = round(
    c(accuracy_30, precision_30, recall_30, f1_30),
    4
  )
)

print(results)

write.csv(
  results,
  "model_evaluation_results.csv",
  row.names = FALSE
)


# ============================================================
# STEP 16: THRESHOLD COMPARISON PLOT (ADDED GRAPH)
# NOTE: EXPLORATORY; USE TRAINING DATA FOR FINAL SELECTION
# ============================================================

thresholds <- seq(0.10, 0.90, by = 0.05)

threshold_results <- do.call(
  rbind,
  lapply(thresholds, function(threshold) {
    
    predicted <- factor(
      ifelse(probabilities >= threshold, "TRUE", "FALSE"),
      levels = c("FALSE", "TRUE")
    )
    
    cm <- table(
      Actual = actual_class,
      Predicted = predicted
    )
    
    tn <- cm["FALSE", "FALSE"]
    fp <- cm["FALSE", "TRUE"]
    fn <- cm["TRUE", "FALSE"]
    tp <- cm["TRUE", "TRUE"]
    
    acc <- (tp + tn) / sum(cm)
    
    prec <- ifelse(
      tp + fp == 0, 0, tp / (tp + fp)
    )
    
    rec <- ifelse(
      tp + fn == 0, 0, tp / (tp + fn)
    )
    
    f1 <- ifelse(
      prec + rec == 0,
      0,
      2 * prec * rec / (prec + rec)
    )
    
    data.frame(
      Threshold = threshold,
      Accuracy = acc,
      Precision = prec,
      Recall = rec,
      F1_Score = f1
    )
  })
)

threshold_plot_data <- rbind(
  data.frame(
    Threshold = threshold_results$Threshold,
    Metric = "Accuracy",
    Score = threshold_results$Accuracy
  ),
  data.frame(
    Threshold = threshold_results$Threshold,
    Metric = "Precision",
    Score = threshold_results$Precision
  ),
  data.frame(
    Threshold = threshold_results$Threshold,
    Metric = "Recall",
    Score = threshold_results$Recall
  ),
  data.frame(
    Threshold = threshold_results$Threshold,
    Metric = "F1-score",
    Score = threshold_results$F1_Score
  )
)

ggplot(
  threshold_plot_data,
  aes(x = Threshold, y = Score, color = Metric)
) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    title = "Model Performance at Different Thresholds",
    subtitle = "Exploratory comparison on the test set",
    x = "Classification Threshold",
    y = "Metric Score",
    color = "Metric"
  ) +
  theme_minimal()


# ============================================================
# STEP 17: PURCHASE OUTCOME BY VISITOR TYPE
# ============================================================

ggplot(data, aes(x = VisitorType, fill = Revenue)) +
  geom_bar(position = "fill") +
  labs(
    title = "Purchase Outcome by Visitor Type",
    x = "Visitor Type",
    y = "Proportion of Sessions",
    fill = "Purchase"
  ) +
  theme_minimal()


# ============================================================
# STEP 18: PURCHASE PROPORTION BY VISITOR TYPE
# ============================================================

purchase_summary <- aggregate(
  I(Revenue == "TRUE") ~ VisitorType,
  data = data,
  FUN = mean
)

names(purchase_summary)[2] <- "Purchase_Proportion"

print(purchase_summary)


# ============================================================
# STEP 19: FINAL CASE STUDY SUMMARY
# ============================================================

cat("\n--- CASE STUDY SUMMARY ---\n")
cat("Total sessions:", nrow(data), "\n")
cat("Total variables:", ncol(data), "\n")
cat("Training sessions:", nrow(train_data), "\n")
cat("Testing sessions:", nrow(test_data), "\n")

cat("\n--- Results at Threshold 0.30 ---\n")
cat("Accuracy:", round(accuracy_30 * 100, 2), "%\n")
cat("Precision:", round(precision_30 * 100, 2), "%\n")
cat("Recall:", round(recall_30 * 100, 2), "%\n")
cat("F1-score:", round(f1_30 * 100, 2), "%\n")
