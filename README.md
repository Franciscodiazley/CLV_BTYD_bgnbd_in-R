# CLV_BTYD_bgnbd_in-R
CLV calculation using package Buytillyoudie_bgngd in R 
# Customer Lifetime Value (CLV) Calculation

Accurately calculating the Customer Lifetime Value (CLV) is crucial for businesses to make decisions about how to acquire and retain customers. This calculation is framed within the Customer-based Corporate Valuation concept and incorporates customer future behavior into traditional financial cash flow calculations in order to forecast the revenues of the company. What I like the most about this calculation is that it allows the company to do sustainable forecasting of the business instead of relying on traditional short-term financial metrics.

## Dataset Generation

The `generate_dataset.R` script generates a synthetic dataset of customer transactions, simulating a real-world scenario. This dataset will be used to calculate the CLV.

## CLV Calculation

The `clv_calculation.R` script calculates the CLV based on historical transaction data. The steps include:
1. Calculating the historical value based on the purchases made by each customer.
2. Predicting the future value of each customer by multiplying the average spent money per transaction by the predicted transactions and applying a daily discount rate.
3. Calculating the acquisition costs as the marketing costs during the observation period divided by the total number of clients.
4. Combining these components to compute the CLV: CLV= (Historical Value+ Future Value) - Acquisition Costs

## How to Use

1. Clone the repository.
2. Run the `generate_dataset.R` script to generate the dataset.
3. Run the `clv_calculation.R` script to calculate the CLV.

## Installation

Make sure you have the necessary libraries installed. You can install them using:

```R
if (!requireNamespace("BTYD", quietly = TRUE)) {install.packages("BTYD")}
if (!requireNamespace("BTYDplus", quietly = TRUE)) {install.packages("BTYDplus")}
if (!requireNamespace("dplyr", quietly = TRUE)) {install.packages("dplyr")}
if (!requireNamespace("lubridate", quietly = TRUE)) {install.packages("lubridate")}
if (!requireNamespace("ggplot2", quietly = TRUE)) {install.packages("ggplot2")}
if (!requireNamespace("scales", quietly = TRUE)) {install.packages("scales")}
