
# SHEIN Product Data Cleaning & Business Intelligence


This project is a complete, production-grade data pipeline that transforms 36,000+ raw, messy SHEIN product records (scraped from Kaggle) across 12 categories into clean, analysis-ready tables and delivers five high-impact, stakeholder-ready business recommendations.


## Dataset

- Source: [Dirty E-Commerce Data [80,000+ Products]](https://www.kaggle.com/datasets/oleksiimartusiuk/e-commerce-data-shein)
- Each product record contains details such as:
    - Product Title 
    - Category
    - Price
    - Discount information
    - (and other attributes)


## Objectives

| Question | Business Value |
| :- | :- |
| Which gender-specific item in shein kids category deliver the highest value-for-money? | Top 10 items to promote/bundle → sales lift |
| Does higher color variety (>6 colors) drive stronger engagement in Baby & Maternity — and is there a girls vs boys difference? | Justify adding colors → higher conversion & margin|
| In swimwear & underwear, which gender segments have the lowest discount but highest selling quantity? | items that sell well without deep discounts |
| Are there hidden winners? Low-priced products with top quality rank (1/2) and high engagement |Hidden gems → perfect for flash sales & bundles|
| Can we identify underpenetrated niches? (high avg price + low competition + excellent rating) | launch new premium collections|

## Tools & Technologies
- **Excel + VBA** – Initial preprocessing, normalization, and fallback cleaning when CSV imports failed  

- **MySQL** – Deep cleaning, data type fixes, feature engineering, and full business analysis

- Git & GitHub (version control)

### Two-Phase Cleaning Pipeline

**Phase 1 – Excel + VBA** → (when CSV → MySQL import failed)  
- Removed duplicates  
- Converted “12.5k+” → integers using nested SUBSTITUTE + IF  
- Fixed negative discounts with `=ABS()`  
- Text-to-Columns for rank_title cleanup  
- Custom VBA function to strip non-English characters   
  ```vba
  Function CleanLettersOnly(TextIn As String) As String
      With CreateObject("VBScript.RegExp")
          .Pattern = "[^a-zA-Z]" : .Global = True
          CleanLettersOnly = .Replace(TextIn, "")
      End With
  End Function

**Phase 2 – MySQL** (core transformation + feature engineering)  
- Created **`prepare&clean_queries.txt`** — a custom automation textfile I wrote from scratch that fully standardizes and enriches every category in one run:  
  - Automated backups  
  - Automated **Data Type Preparation** (non-numeric → NULL → proper INT)  
  - Automated **Cleaning** (lowercasing, space collapsing, non-ASCII stripping)**  
  - Automated **Feature Engineering** block:  
    - `category`  
    - `rank_sub` (swimwear, outwear, underwear, footwear, clothing, etc.)  
    - `specific_gender` (men / women / boy / girl / unisex)  
    - `gender` (male / female / unisex)  

## Key Insights

- Color proliferation is not an effective growth lever in shein kids category for either gender.

- Female Underwear/Swimwear, Unisex Underwear sell extremely well at full or near-full price.

- Accessories are by far the most ideal category for bundling and flash-sale promotions

- Outwear is the single most underpenetrated premium niche

## Business Recommendations 
- Maintain lean color palettes (3–6 colors max) to minimize production costs without sacrificing performance

- Unisex and Female Underwear prove customers willingly pay full price — deep discounts here are pure margin leakage.

- Based on Low priced, top quality rank (1 or 2) and the high engagement we can conclude:
  - Accessories are by far the most ideal category for bundling
  - Customers already trust the quality
  - Very high engagement - Proven customer love

- There is an untapped market gap because outwear stands out as the clearest underpenetrated premium niche that's why we need to have a major outwear expansion.

## Repository Structure

```javascript

├── excel/
│   ├──data_raw                            ← link above
│   ├── excel_cleaning_plan.txt            ← My custom automation
│   ├── us-shein_womens_clothing_clean.csv
│   ├── us-shein_baby_and_maternity_clean.csv
│   ├── us-shein_bags_and_luggage_clean.csv
│   ├── us-shein_curve_clean.csv
│   ├── us-shein_jewelry_and_accessories_clean.csv
│   ├── us-shein_kids_clean.csv
│   ├── us-shein_mens_clothes_clean.csv
│   ├── us-shein_shoes_clean.csv
│   ├── us-shein_sports_and_outdoors_clean.csv
│   ├── us-shein_swimwear_clean.csv
│   └── us-shein_underwear_and_sleepwear_clean.csv

├── sql/
│   ├── prepare&clean_queries.txt          ← My custom automation queries(backups + type fixes + cleaning + feature engineering)
│   ├── baby_and_maternity_clean.sql
│   ├── shein_curve.sql
│   ├── mens_clothes.sql
│   ├── womens_clothing.sql
│   ├── bags and luggage.sql
│   ├── swimwear.sql
│   ├── underwear_and_sleepwear.sql
│   ├── shein_kids.sql
│   ├── shein_jewelry_and_accessories.sql
│   ├── shein_shoes.sql
│   ├── shein_sports_and_outdoors.sql
│   └── shein_merged_eda.sql               ← Final merged table creation, descriptive statistics and all 5 business questions + insights 
└── README.md                              ← You are here
}
```
## 🔗 Links
[![portfolio](https://img.shields.io/badge/my_portfolio-000?style=for-the-badge&logo=ko-fi&logoColor=white)](https://github.com/nick-s-data)
[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/nick-starosta-93a512391/)

