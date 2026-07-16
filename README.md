# E-Commerce Retailer Data Analysis

An end-to-end data analytics project built on the **Brazilian Olist E-Commerce Dataset**, combining **SQL, Python, and Power BI** to analyze order fulfillment, delivery performance, revenue trends, and seller insights.

## Overview

This project follows a complete analytics pipeline:

**Raw CSVs → SQL Database → Data Cleaning & Feature Engineering → Exploratory Data Analysis → Power BI Dashboard**

The analysis focuses on answering business questions such as:

- Where do delivery delays occur?
- Which sellers and regions generate the most revenue?
- How do shipping costs impact product prices?
- What are the key revenue trends across years and product categories?

---

## Dataset

This project uses the **Brazilian Olist E-Commerce Public Dataset**, containing approximately **100,000 anonymized orders (2016–2018)**.

The dataset includes information about:

- Orders
- Customers
- Sellers
- Products
- Payments
- Reviews
- Geolocation

> **Note:** The raw dataset is **not included** in this repository. Download it from Kaggle before running the project.

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| MySQL / PostgreSQL | Database & Analytical Views |
| Python | Data Cleaning & Analysis |
| Pandas & NumPy | Data Processing |
| Matplotlib | Data Visualization |
| Power BI | Interactive Dashboard |
| Jupyter Notebook | Analysis Environment |

---

## Project Structure

```text
.
├── 1_SQL/
│   ├── Data_Load_MySQL.sql
│   └── Data_Load_Postgres.sql
│
├── 2_Python/
│   └── Analysis Notebook.ipynb
│
├── 4_Charts/
│   └── Exported visualizations
│
└── README.md
```

---

## Features

### SQL

- Relational database schema
- Data loading scripts
- Analytical SQL views
- Revenue and seller analysis

### Python

- Data cleaning
- Feature engineering
- Delivery lifecycle analysis
- Exploratory data analysis (EDA)

### Dashboard

**Get the dashboard**: [Olist Dashboard](https://drive.google.com/file/d/1FMbvhOEGNoBTBUKB6DJKslQJU2M8gY2a/view)

Interactive Power BI dashboard featuring:

- Revenue KPIs
- Delivery performance
- Seller analysis
- Geographic insights
- Product category analysis

---

## Key Metrics

- Late Delivery Rate
- Revenue by Year
- Revenue by Product Category
- Revenue by State
- Top Sellers by Revenue
- Average Basket Size
- Shipping Cost as Percentage of Item Price

---

## How to Run

1. Download the Olist dataset from Kaggle.
2. Place the CSV files in your local data directory.
3. (Optional) Execute the SQL scripts to create the database.
4. Install Python dependencies:

```bash
pip install pandas numpy matplotlib jupyter
```

5. Open and run:

```text
2_Python/Analysis Notebook.ipynb
```

6. Open the Power BI dashboard in Power BI Desktop.

---

## Key Insights

This project enables analysis of:

- Delivery bottlenecks across the fulfillment process
- Revenue distribution by geography and category
- Seller performance
- Shipping cost impact
- Order lifecycle efficiency

---

## Limitations

- Raw dataset is not included.
- File paths must be updated before execution.
  
---

## Acknowledgements

Dataset provided by **Olist** through the [Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?resource=download).
