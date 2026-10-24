# Sales & Operations MIS Dashboard | PostgreSQL + Excel
An end-to-end **Sales & Operations MIS Dashboard** project built with **PostgreSQL and Microsoft Excel**. The project demonstrates how raw sales data can be inspected, cleaned, analyzed with SQL, and presented in a management-friendly dashboard with KPIs, charts, and interactive filters.

> **Portfolio project:** MIS Executive / Data Analyst Fresher  
> **Dataset:** 25,000 sales-order records  
> **Data period:** 1 January 2025 – 31 December 2025  
> **Currency:** Indian Rupees (INR, ₹)

---

## Dashboard Preview

![Sales & Operations MIS Dashboard](https://github.com/Devmurari0205/sales-operations-mis-dashboard/blob/main/dashboard/Screenshot%202026-10-24%20184734.png)

The dashboard includes KPI cards, monthly net-sales trend, region-wise sales, sales-channel performance, product-category performance, order-status mix, top 10 cities by net sales, payment-method mix, and interactive Excel slicers.

**Important:** The dashboard image is a screenshot of the Excel workbook. Results reflect the workbook's current calculation and status-handling rules. Before treating the figures as audited financial results, review the data-quality and business-rule notes below—especially Cancelled/Returned orders and missing cost values.

---

## Business Problem

Sales and operations teams need a single view of business performance to answer questions such as:

- What are the total net sales, gross sales, profit, and profit margin?
- How do sales and profit change month by month?
- Which regions, sales channels, and product categories contribute the most revenue?
- Which cities have the highest net sales?
- What is the distribution of order statuses and payment methods?
- Which records require data-quality review before management reporting?

This project uses SQL for data preparation and analysis, then Excel to turn the results into a dashboard that can be explored through filters.

## Project Objectives

1. Import raw sales records into PostgreSQL.
2. inspect the source data for missing values, duplicate IDs, and invalid values.
3. Create a cleaned table with standardized text fields and calculated sales measures.
4. Write SQL queries for business KPIs and performance analysis.
5. Prepare summary data for charts and reporting.
6. Build an Excel dashboard with KPI cards, charts, and slicers.
7. Document findings and data-quality limitations in a portfolio-ready format.

## Tools & Technologies

- **PostgreSQL** — importing data, SQL data cleaning, aggregation, validation, KPI calculations, and views.
- **Microsoft Excel** — PivotTables, charts, KPI cards, formatting, and slicers.
- **CSV** — raw and cleaned data exchange.
- **Microsoft Word** — documentation of SQL queries and their purpose.
- **GitHub** — version control and portfolio presentation.

## Repository Contents

Recommended GitHub repository structure:

```text
sales-operations-mis-dashboard/
├── README.md
├── sales_operations.csv
├── sales_operations_clean.csv
├── sales_operations_mis.sql
├── Sales Operations Queries.docx
├── Sale_operations_dashboard.xlsx
└── dashboard.png
```

### File guide

| File | Description |
|---|---|
| `sales_operations.csv` | Raw sales dataset used as the source for the project. |
| `sales_operations_clean.csv` | Cleaned-data sheet exported from the Excel workbook for convenient review and reuse. For the authoritative cleaning logic, review the SQL script. |
| `sales_operations_mis.sql` | PostgreSQL script for table creation, importing guidance, data checks, cleaning, deduplication, KPIs, trend analysis, and summary views. |
| `Sales Operations Queries.docx` | Human-readable document containing selected SQL queries grouped by analysis topic. |
| `Sale_operations_dashboard.xlsx` | Excel workbook containing the dashboard, cleaned-data sheet, and PivotTable/reporting sheet. |
| `dashboard.png` | Screenshot used for the dashboard preview in this README. |

> If you use different filenames on GitHub, update the links and the image path in this README to match them exactly. GitHub filenames are case-sensitive.

## Dataset Overview

The source dataset contains **25,000 rows and 21 columns**. The fields describe order dates, customer and location details, product information, sales values, costs, payment method, order status, and sales representatives.

| Column | Description |
|---|---|
| `order_id` | Unique identifier assigned to an order. |
| `order_date` | Date the order was placed. |
| `ship_date` | Date the order was shipped. |
| `delivery_date` | Date the order was delivered, where available. |
| `customer_name` | Customer or organization name. |
| `region` | Sales region. |
| `city` | Customer/order city. |
| `sales_channel` | Channel through which the order was placed. |
| `product_category` | Broad product category. |
| `product_name` | Product name. |
| `quantity` | Units ordered. |
| `unit_price_inr` | Unit price in INR. |
| `discount_pct` | Discount rate stored as a decimal fraction (for example, `0.10` represents 10%). Confirm this convention against the source before applying changes. |
| `gross_sales_inr` | Gross sales before discount. |
| `discount_amount_inr` | Discount amount in INR. |
| `net_sales_inr` | Net sales after discount. |
| `estimated_cost_inr` | Estimated product/order cost in INR. |
| `profit_inr` | Profit measure in INR. |
| `payment_method` | Payment method used. |
| `order_status` | Current order status. |
| `sales_rep` | Sales representative identifier. |

## Data Preparation & Cleaning

The PostgreSQL script demonstrates the following steps:

1. Create a source table named `sales_operations`.
2. Check the row count and preview records.
3. Identify duplicate `order_id` values.
4. Check selected fields for missing or blank values.
5. Standardize text fields by trimming whitespace and normalizing capitalization.
6. Calculate/recalculate discount, net-sales, and profit fields.
7. Create a deduplicated table using PostgreSQL `DISTINCT ON`.
8. Run validation queries on the cleaned and deduplicated data.
9. Create business summaries and a monthly reporting view.

### Data-quality points to review

The uploaded source file includes missing values in several fields. In particular, missing `delivery_date` can be expected for orders that have not been delivered, but a Delivered order without a delivery date should be reviewed. Missing quantity, discount, sales, cost, or profit values should also be investigated before reporting.

The SQL script currently contains logic that should be checked before final publication:

- **Deduplication:** `DISTINCT ON (order_id)` keeps one record per order ID, ordered by order date. This is appropriate only if one row per order is the intended business rule. Inspect duplicates before discarding records.
- **Missing costs:** replacing a missing estimated cost with zero when calculating profit can overstate profit. Prefer leaving profit unavailable or flagging the row for review until the true cost is confirmed.
- **Discount bands:** if `discount_pct` is stored as a fraction from `0` to `1`, use boundaries such as `0.05` for 5% and `0.10` for 10%. Confirm the data convention and correct the band conditions before using the discount analysis.
- **Delivery-time analysis:** calculate delivery duration only for Delivered records with both `order_date` and `delivery_date` populated. The current SQL's `delivery_date IS NULL` filter does not calculate completed delivery times and should be corrected.
- **Order-status casing:** standardize status values or compare with `LOWER(order_status) = 'delivered'` so capitalization differences do not exclude records.
- **Sales totals by status:** the dashboard's current totals include all order statuses. Decide how Cancelled and Returned orders should affect recognized sales and profit before presenting final business totals.
- **Financial rounding:** round the final aggregate/ratio for display, rather than rounding each row unnecessarily. Keep calculated currency values to two decimal places where appropriate.

These notes are intentionally documented so the project demonstrates not only reporting, but also data validation and business awareness.

## SQL Analysis Included

The SQL script and query document cover the following analysis areas:

1. **Core KPIs** — net sales, gross sales, order count, total profit, average order value, and profit margin.
2. **Monthly trend** — monthly net sales, profit, and order volume.
3. **Region-wise performance** — orders, net sales, profit, and profit margin by region.
4. **Product-category performance** — units, net sales, and profit by category.
5. **Top 10 cities** — cities ranked by net sales.
6. **Sales-channel performance** — orders, net sales, profit, and margin by channel.
7. **Order-status summary** — order count and net sales by status.
8. **Discount impact** — order and sales totals by discount band.
9. **Payment-method mix** — orders and net sales by payment method.
10. **Month-over-month change** — current-month sales, previous-month sales, and percentage change using `LAG()`.
11. **Sales representative performance** — orders, net sales, and profit by representative.
12. **Top customers** — customers ranked by net sales.
13. **Monthly MIS view** — a grouped view for reporting by month, region, category, and channel.
14. **Delivery-time review** — delivery duration and delayed deliveries, after the query logic is corrected as described above.

### KPI definitions

| KPI | Definition |
|---|---|
| Net Sales | Sum of `net_sales_inr`. Confirm treatment of Cancelled and Returned orders. |
| Gross Sales | Sum of `gross_sales_inr`, or quantity × unit price if the source value is not trusted. |
| Total Orders | Count of distinct `order_id` values. |
| Total Profit | Sum of `profit_inr` for records whose cost/profit data has been validated. |
| Average Order Value (AOV) | Net sales ÷ distinct order count. |
| Profit Margin | Total profit ÷ total net sales × 100. |
| Monthly Sales Growth | (Current month sales − previous month sales) ÷ previous month sales × 100. |
| Order-to-Delivery Days | `delivery_date − order_date` for Delivered orders with both dates present. |

## Excel Dashboard Features

The dashboard presents a management-level view with:

- **KPI cards:** Net Sales, Gross Sales, Orders, Total Profit, Average Order Value, and Profit Margin.
- **Monthly net-sales trend:** line chart to see monthly performance.
- **Net sales by region:** horizontal bar chart for regional comparison.
- **Sales by channel:** column chart to compare channel contribution.
- **Top product category:** bar chart to compare categories.
- **Order-status mix:** chart showing the order lifecycle distribution.
- **Top 10 cities by net sales:** ranked horizontal bar chart.
- **Payment-method mix:** chart showing payment-method contribution.
- **Interactive filters/slicers:** region, order status, sales channel, and product category.

### Dashboard design choices

- Dark navy background for a professional MIS/BI look.
- White text and borders for contrast.
- Teal, blue, and gold accents to distinguish measures and categories.
- KPI cards placed at the top for quick executive reading.
- Bar charts for category/region comparisons, a line chart for time trends, and a mix chart for categorical composition.

## How to Reproduce the Project

### 1. Create a PostgreSQL database

Open pgAdmin or `psql`, create a database for the project, and connect to it. Example database name: `sales_operations_db`.

### 2. Run the SQL script

Open `sales_operations_mis.sql` in pgAdmin's Query Tool and review the script before running it. The script includes `DROP TABLE` statements, which delete existing tables with matching names. Back up any important data and confirm the selected database before execution.

### 3. Import the raw CSV

The SQL file creates the table schema and includes import guidance. In pgAdmin, right-click the `sales_operations` table and choose **Import/Export Data**. Select the raw CSV, set format to CSV, enable the header option if the file contains column headers, and confirm the delimiter and column order before importing.

Alternatively, use PostgreSQL's `\copy` command from `psql`, adapting the file path to your computer.

### 4. Run validation and cleaning queries

Run the row-count, missing-value, duplicate, and range-check queries. Review the business-rule warnings above and correct the related SQL before treating the output as final.

### 5. Review the analysis queries

Run the KPI and summary queries individually. Check that the totals reconcile with the cleaned data and that order-status logic matches your reporting definition.

### 6. Open the Excel dashboard

Open `Sale_operations_dashboard.xlsx`, enable editing if prompted, and use the dashboard's filters/slicers. If the workbook is connected to PivotTables, refresh it after replacing or updating the underlying data. Use **Data → Refresh All** when applicable.

## Key Insights / What This Project Demonstrates

This repository is designed to demonstrate the ability to:

- transform raw order records into a structured analytical table;
- write SQL using aggregation, `GROUP BY`, `CASE`, date functions, window functions, and views;
- calculate business KPIs such as sales, profit, AOV, and margin;
- compare performance across time, regions, categories, channels, and cities;
- design an Excel dashboard with interactive filtering;
- recognize data-quality issues and explain how they affect management reporting.

**Do not claim a specific business improvement or financial outcome unless you have calculated and validated it.** Add 2–4 quantified findings here after reviewing the corrected query outputs—for example, the top-performing region, highest-sales category, strongest sales channel, or month with the highest sales.

## Future Improvements

- Correct and document the business rules for Cancelled and Returned orders.
- Add a dedicated data-quality report and exception flags.
- Reconcile row-level sales/profit calculations with source values.
- Correct the discount-band and delivery-duration SQL conditions.
- Add month-over-month KPI cards and conditional formatting.
- Add slicer connections for every PivotTable/PivotChart on the dashboard.
- Create a refresh workflow so new source rows can be added without rebuilding the report.
- Add a short `docs/` section with query outputs and dashboard screenshots.

## Author

**Harsh Devmurari**  
Aspiring MIS Executive / Data Analyst

- GitHub: []
- LinkedIn: []

## Disclaimer

This is a portfolio/practice project using a sales-order dataset. Financial metrics are analytical outputs from the included data, not audited financial statements. Validate the dataset, formula conventions, status rules, and SQL logic before using the figures for operational or financial decisions
