# E-commerce Funnel Analysis | SQL Product Analytics Case Study

**A data-driven investigation of product-view, add-to-cart, and purchase behavior using SQL and DuckDB.**

[![SQL](https://img.shields.io/badge/SQL-Analytics-blue.svg)](https://duckdb.org/docs/)
[![Python](https://img.shields.io/badge/Python-Analysis-yellow.svg)](https://www.python.org/)
[![DuckDB](https://img.shields.io/badge/DuckDB-Query%20Engine-orange.svg)](https://duckdb.org/)
[![Kaggle](https://img.shields.io/badge/Data-Kaggle-20BEFF.svg)](https://www.kaggle.com/)

## 1. Project Overview

Why do so many customers who view a product never proceed to purchase?

This project analyzes e-commerce behavioral event data to quantify conversion across three stages of the shopping journey:

**Product View → Add to Cart → Purchase**

Using SQL and DuckDB, I built a sequential funnel, calculated stage-level conversion rates, explored category and brand performance, and identified potential areas for further product investigation.

The objective was not just to calculate metrics, but to translate behavioral data into actionable product hypotheses.

## 2. Business Problem

E-commerce businesses generate large volumes of product interactions, but activity does not necessarily translate into purchases.

Understanding where potential customers drop off can help product teams prioritize investigations into product discovery, product-page usability, pricing, availability, and checkout friction.

**Key business question:** At which stage does the largest observed drop-off occur, and what should the product team investigate first?

## 3. Dataset

- **Dataset:** [eCommerce Behavior Data from Multi-Category Store](https://www.kaggle.com/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store)
- **Data period analyzed:** November 2019
- **Source:** Kaggle
- **Data type:** E-commerce behavioral event logs

Relevant fields include:

| Column | Description |
|---|---|
| `event_time` | Timestamp of the event |
| `event_type` | Event type, such as view, cart, or purchase |
| `product_id` | Product identifier |
| `category_code` | Product category hierarchy |
| `brand` | Product brand |
| `price` | Product price |
| `user_id` | User identifier |
| `user_session` | Session identifier |

The original dataset is large, so the analysis was performed in a cloud notebook using DuckDB rather than downloading the full dataset locally.

## 4. Tools and Technologies

- **SQL:** Filtering, aggregation, conditional logic, event sequencing, and funnel calculations
- **DuckDB:** Analytical SQL queries over CSV data
- **Python:** Notebook execution and result inspection
- **Kaggle Notebooks:** Cloud-based analysis environment

## 5. Methodology

### Step 1 — Event exploration

Examined event volumes and distinct users across views, cart additions, and purchases to understand the scale and composition of the data.

### Step 2 — Journey definition

Defined a product journey at the following grain:

`user_id + user_session + product_id`

This allows multiple product interactions within the same session to be analyzed separately.

A journey is not equivalent to a unique customer or a unique order.

### Step 3 — Sequential funnel construction

Built a funnel that requires:

1. A product view.
2. A cart event occurring at or after the first view.
3. A purchase event occurring at or after the qualifying cart event.

This is more precise than counting event types without considering their order.

## Funnel Visualization

![E-commerce Conversion Funnel](visuals/funnel_chart.png)

### Step 4 — Conversion measurement

Calculated the following metrics:

- View-to-cart conversion
- Cart-to-purchase conversion
- Overall view-to-purchase conversion

### Step 5 — Category and brand exploration

Explored conversion differences across categories and brands to identify possible areas for further investigation.

**Validation note:** Category and brand results are exploratory. Their corrected aggregation has not been fully validated, so they are not used as confirmed findings in this report.

## 6. Key Results

The validated sequential funnel for November 2019 produced the following results.

| Funnel metric | Journeys |
|---|---:|
| Product-view journeys | 41,949,801 |
| Cart-after-view journeys | 2,036,785 |
| Sequentially completed journeys | 705,988 |

### Conversion metrics

| Metric | Result |
|---|---:|
| View → Cart | 4.86% |
| Cart → Purchase | 34.66% |
| View → Purchase | 1.68% |

*Rates are rounded to two decimal places. The calculations use product-view journeys as the starting population.*

## Key Insights

### 1. The largest drop-off occurs before cart addition

Only 4.86% of product-session journeys with a view progressed to a qualifying cart event. This indicates that the view-to-cart stage is the main observed conversion bottleneck in this funnel.

### 2. A smaller share of journeys progresses beyond the cart

Of journeys that reached the cart after a view, 34.66% subsequently recorded a purchase event. This suggests an opportunity to investigate friction between cart addition and purchase.

### 3. Overall sequential conversion is low

The reported view-to-purchase conversion rate was 1.68% at the product-session-product journey level.

These findings are descriptive. They identify where users drop out of the observed funnel but do not establish why they drop out.

### Measurement approach

Establish a baseline, run controlled A/B tests where feasible, and compare conversion rates alongside guardrail metrics such as average order value, refunds, and checkout errors.

Do not assume that a proposed change will improve conversion until its impact is measured.

## 8. Product Recommendations

### Recommendation 1 — Investigate product-page performance

Examine product-page exits, add-to-cart interactions, pricing, stock availability, delivery information, and mobile usability.

**Primary metric:** View-to-cart conversion rate.

### Recommendation 2 — Investigate cart abandonment

Review checkout steps, shipping charges, payment failures, delivery estimates, and unexpected costs.

**Primary metric:** Cart-to-purchase conversion rate.

### Recommendation 3 — Test a targeted product improvement

Design a controlled experiment around a specific product-page or checkout hypothesis.

For a product-page experiment, use view-to-cart conversion as the primary metric and purchase conversion as a secondary metric. Define an appropriate experiment duration, sample size, and guardrail metrics before launch.

No conversion uplift is claimed because no controlled experiment has been conducted.

## 9. Limitations

- **Journey-level metrics:** Results represent product-session-product journeys, not unique customers, orders, or revenue.
- **Observational analysis:** The funnel shows associations and progression, not the causes of abandonment.
- **Event tracking:** Missing or incorrectly recorded events may affect measured conversion.
- **Time boundaries:** The analysis covers events recorded in the November 2019 dataset. Journeys spanning the dataset's time boundaries may be incomplete.
- **Category analysis:** Category-level results should be validated independently before drawing conclusions.
- **No causal testing:** Product recommendations are hypotheses and require controlled experiments or further analysis.
- **Reproducibility:** Reported metrics must be checked against the saved SQL queries before being treated as independently verified results.

These limitations should be considered before using the findings to make business decisions.

## 10. Project Structure

The repository is intended to contain the following materials as they are finalized:

```text
SQL-focused-Product-Analytics-case-study/
├── README.md
├── sql/
│   ├── event_exploration.sql
│   ├── funnel_analysis.sql
│   └── category_analysis.sql
├── notebooks/
│   └── ecommerce_funnel_analysis.ipynb
├── visuals/
│   └── funnel_chart.png
└── reports/
    └── project_report.pdf
```

File names above describe the proposed organization; not all files may be present yet.

## 11. Reproducibility

The original dataset is available on [Kaggle](https://www.kaggle.com/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store).

To reproduce the analysis:

1. Open the dataset page and add the dataset to a Kaggle Notebook.
2. Install DuckDB if it is not already available.
3. Configure the CSV file path for the November 2019 data.
4. Run the SQL queries in the notebook.
5. Compare the output against the funnel definitions and reported metrics in this README.

The full raw dataset is not included in this repository because of its size.

## 12. Conclusion

This project demonstrates how SQL can be used to turn raw behavioral events into a structured conversion funnel.

The validated results highlight the product-view-to-cart transition as the largest observed drop-off and provide a basis for further investigation into product-page performance and checkout friction.

The next analytical step is to validate category-level differences, investigate the underlying causes, and test targeted improvements using measurable product metrics.

---

**Project focus:** Product Analytics · SQL · Funnel Analysis · Conversion Metrics · Business Problem-Solving

**Author:** [Hrishit Saha](https://github.com/hrishit06)
