# Week 5 Spark Assignment

## Objective
Learn the basics of Apache Spark, DataFrames, and perform data cleaning, transformation, and aggregation.

## Steps Performed
1. **Mock Data Creation:** Generated a dummy dataset containing edge cases like null values, empty strings, and duplicates.
2. **Data Cleaning:** Removed duplicate rows and handled null values using `.na.fill()`.
3. **Transformations & Filtering:** Filtered data by age and region, casted timestamp columns, and renamed them.
4. **Aggregation Pipeline:** Created a final pipeline to clean data, replace missing prices with 0, and group by `store_id` to calculate total revenue.

## Observations
* **In-Memory Processing:** Spark's ability to keep data in memory makes iterative processing significantly faster than disk-heavy MapReduce.
* **Immutability:** Modifying DataFrames (like dropping columns) doesn't change the original data; it creates a new DataFrame representing the cleaned state, which makes building pipelines safe and predictable.