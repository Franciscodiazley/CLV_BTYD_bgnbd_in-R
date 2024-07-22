
### `generate_dataset.R`

```r
# Load necessary library
library(dplyr)

# Set seed for reproducibility
set.seed(123)

# Define the number of transactions
n_transactions <- 10000

# Define the number of unique customers
n_customers <- round(n_transactions / 5)  # Based on mean order count

# Generate customer_id: 8 digit numbers
customer_ids <- sprintf("%08d", sample(1:99999999, n_customers, replace = FALSE))

# Ensure 80% of customers make more than one order, with an average of 5 orders
repeat_customers <- sample(customer_ids, 0.8 * n_customers)
single_order_customers <- setdiff(customer_ids, repeat_customers)

# Generate orders for repeat customers
repeat_orders <- unlist(lapply(repeat_customers, function(id) {
  num_orders <- rpois(1, lambda = 4) + 1  # At least one repeat order (total at least 2 orders)
  rep(id, num_orders)
}))

# Generate orders for single order customers
single_orders <- rep(single_order_customers, each = 1)

# Combine all orders
all_customer_ids <- c(repeat_orders, single_orders)
all_customer_ids <- sample(all_customer_ids, n_transactions, replace = TRUE)  # Shuffle to mix orders

# Generate transaction_id: 4 digit numbers
transaction_id <- sprintf("%04d", sample(1:9999, n_transactions, replace = TRUE))

# Generate transaction_date_id: dates between 2017-01-01 and 2018-12-31
start_date <- as.Date("2017-01-01")
end_date <- as.Date("2018-12-31")
date_sequence <- seq.Date(start_date, end_date, by = "day")
transaction_date_id <- sample(date_sequence, n_transactions, replace = TRUE)

# Generate amount_dollar: random amounts between 0 and 100
amount_dollar <- round(runif(n_transactions, min = 0, max = 100), 2)

# Create the dataset
dataset <- data.frame(
  transaction_id = transaction_id,
  customer_id = all_customer_ids,
  transaction_date_id = transaction_date_id,
  amount_dollar = amount_dollar
)

# Group the dataset by customer_id and count the number of transactions per customer
customer_transactions <- dataset %>%
  group_by(customer_id) %>%
  summarise(transaction_count = n()) %>%
  arrange(desc(transaction_count))

# Display customers with more than one transaction
customers_with_multiple_transactions <- customer_transactions %>%
  filter(transaction_count > 1)

# Print the first few rows of customers with multiple transactions
print(head(customers_with_multiple_transactions))

# Save the dataset to a CSV file
file_path <- "aleatory_dataset.csv"
write.csv(dataset, file_path, row.names = FALSE)

