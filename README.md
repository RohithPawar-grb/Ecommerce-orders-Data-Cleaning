# Data Quality Assessment & Cleaning Analysis (SQL)

## Project Overview
This project focuses on data cleaning, validation, and data-quality analysis for an e-commerce transactional system using PostgreSQL SQL.

The objective is to assess whether raw business data is reliable and usable for reporting.  
Instead of dashboards, this project emphasizes data trust, consistency, and business impact of poor data quality.

All cleaning is done using SQL views while preserving raw source tables.

---

## Dataset Description

### Customers Table
- customer_id  
- customer_name  
- email  
- phone  
- city  
- state  
- signup_date  

### Products Table
- product_id  
- product_name  
- category  
- price  
- seller_city  

### Orders Table
- order_id  
- order_date  
- customer_id  
- product_id  
- quantity  
- order_status  
- payment_mode  

All columns are initially stored as TEXT to simulate real-world messy ingestion.

---

## Data Cleaning Strategy

### Key Principle
Raw data is never modified.  
All transformations are applied using SQL views for auditability and traceability.

---

### Customer Data Cleaning (`customer_clean`)
- Trimmed and standardized customer names
- Validated phone numbers (10-digit format)
- Normalized city and state names
- Converted signup dates from multiple formats
- Removed duplicate customer records using window functions

---

### Product Data Cleaning (`product_clean`)
- Standardized product names and categories
- Removed blank, negative, and non-numeric prices
- Created a valid_price flag
- Standardized seller city values
- Removed duplicate product records

---

### Orders Data Cleaning (`orders_clean`)
- Parsed multiple order date formats and removed timestamps
- Validated quantity values (numeric and positive)
- Standardized order status and payment mode
- Created data-quality flags:
  - quantity_clean_flag
  - order_date_clean_flag
  - valid_data
- Removed duplicate orders

---

## Data Quality & Business Analysis

This project answers real operational and data-quality questions such as:

- How many total, completed, cancelled, and returned orders exist?
- How many orders contain invalid or missing quantities?
- How many orders have invalid or missing order dates?
- What percentage of data becomes usable after cleaning?
- Which completed orders cannot generate revenue due to missing data?
- Which cities have the highest number of broken completed orders?
- Which products appear most frequently in orders with missing critical data?
- Are data-quality issues concentrated in specific cities?
- Which products should be audited first due to repeated data issues?

---

## Key Insights
- Completed orders may still fail revenue reporting due to missing price or quantity
- Data-quality issues are not evenly distributed across cities and products
- Cleaning via SQL views preserves raw data integrity
- Reliable reporting requires data validation before analysis

---

## Tools Used
- PostgreSQL
- SQL (Views, CTEs, Window Functions, Regex, Conditional Logic)

---

## Project Structure
├── raw_tables.sql
├── cleaning_views.sql
├── analysis_queries.sql
└── README.md


## Author-
## Rohith Pawar
linkedin - www.linkedin.com/in/rohith-pawar-557293346
---
mail- rohitvilaspawar1@gmail.com

## Thank You.
