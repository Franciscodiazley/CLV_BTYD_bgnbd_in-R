# Install necessary libraries
if (!requireNamespace("BTYD", quietly = TRUE)) {install.packages("BTYD")}
if (!requireNamespace("BTYDplus", quietly = TRUE)) {install.packages("BTYDplus")}
if (!requireNamespace("dplyr", quietly = TRUE)) {install.packages("dplyr")}
if (!requireNamespace("lubridate", quietly = TRUE)) {install.packages("lubridate")}
if (!requireNamespace("ggplot2", quietly = TRUE)) {install.packages("ggplot2")}
if (!requireNamespace("scales", quietly = TRUE)) {install.packages("scales")}

library(BTYD)
library(BTYDplus)
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)

# Load historical transaction log data
tlog <- read.csv("aleatory_dataset.csv")

# Check the columns of the dataset
head(tlog)

# Ensure date is in the correct date format
tlog$transaction_date_id <- as.Date(tlog$transaction_date_id, format = "%Y-%m-%d")

# Change the name of the data frame, so we don’t modify the original document
clv_data <- tlog

# Set the end date for the calibration period
calibration_end_date <- as.Date("2018-12-31")

# Calculate the frequency, recency, and total observation time for each customer
cbs_data <- clv_data %>%
  group_by(customer_id) %>%
  summarise(
    frequency = n() - 1,  # Number of repeat transactions (total transactions - 1)
    recency = as.numeric(difftime(max(transaction_date_id), min(transaction_date_id), units = "days")),
    T.cal = as.numeric(difftime(calibration_end_date, min(transaction_date_id), units = "days"))
  ) %>%
  filter(frequency > 0)  # Keep only customers with more than 1 purchase

# Create the event log for BTYDplus
elog <- clv_data %>% 
  select(customer_id, transaction_date_id, amount_dollar) %>% 
  rename(cust = customer_id, date = transaction_date_id, sales = amount_dollar) %>% 
  arrange(cust, date)

# Create the CBS (Customer by Sufficient Statistics) data frame using BTYDplus
customer_rdf <- BTYDplus::elog2cbs(elog, units = "days", T.cal = calibration_end_date)

# Estimate parameters using BG/NBD
params_bgnbd <- BTYD::bgnbd.EstimateParameters(customer_rdf)

# Predict future transactions for each customer over a period of 1 year (365 days)
T.star <- 365
customer_rdf$predicted_bgnbd <- BTYD::bgnbd.ConditionalExpectedTransactions(
  params = params_bgnbd,
  T.star = T.star,
  x = customer_rdf$x,
  t.x = customer_rdf$t.x,
  T.cal = customer_rdf$T.cal
)

# Add predicted transactions column to the original CBS data frame
customer_rdf <- customer_rdf %>%
  mutate(predicted_transactions = BTYD::bgnbd.ConditionalExpectedTransactions(
    params = params_bgnbd,
    T.star = T.star,
    x = x,
    t.x = t.x,
    T.cal = T.cal
  ))

# Calculate the historical value based on purchases made by each customer
historical_value <- clv_data %>%
  group_by(customer_id) %>%
  summarise(historical_value = sum(amount_dollar))

# Merge historical value with customer_rdf
customer_rdf <- customer_rdf %>%
  left_join(historical_value, by = c("cust" = "customer_id"))

# Calculate the average amount spent per transaction for each customer
average_spent_per_transaction <- clv_data %>%
  group_by(customer_id) %>%
  summarise(avg_amount = mean(amount_dollar))

# Merge average amount spent per transaction with customer_rdf
customer_rdf
