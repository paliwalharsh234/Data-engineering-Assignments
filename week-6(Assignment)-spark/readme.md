# Apache Spark Data Processing Pipeline

## Overview
This repository contains the implementation of a PySpark data processing pipeline. It demonstrates core Apache Spark concepts, including schema handling, DataFrame transformations, filtering, and optimized file storage. 

## Architectural Insights
* **Driver & Executor Model:** This application operates on a distributed architecture. The central **Driver** creates the SparkSession and converts the code into a logical plan, while the **Executors** (worker nodes) carry out the actual data processing tasks in parallel.
* **Execution Modes:** This code is designed to be adaptable. It can run in **Client Mode** (ideal for interactive environments like notebooks, where the driver stays with the user) or be deployed in **Cluster Mode** (where the cluster manager hosts the driver for better production stability).
* **Fault Tolerance via Lineage:** Spark does not constantly write intermediate data to disk. Instead, it builds a **Directed Acyclic Graph (DAG)** of all transformations. If a worker node crashes, Spark uses this lineage graph to perfectly recompute only the lost data partitions.

## Performance Optimizations
* **Lazy Evaluation:** Spark delays executing any transformations (like `filter` or `withColumn`) until an action (like `.show()` or `.write()`) is called. This allows Spark's Catalyst Optimizer to analyze the entire chain of commands and create the most efficient execution plan possible.
* **Columnar Storage (Parquet vs. CSV):** The pipeline highlights the transition from row-based CSVs to **Parquet**. Because Parquet is a columnar format, analytical queries run drastically faster by only reading the specific columns requested, heavily reducing disk I/O and memory footprint.
* **Predicate Pushdown:** When reading from Parquet, Spark utilizes predicate pushdown. Filters are pushed directly to the storage layer, allowing Spark to use file metadata to skip entirely irrelevant blocks of data before they are even loaded into memory.
* **Memory Management:** For data exploration, `.show()` is strictly used over `.collect()`. Pulling multi-terabyte datasets back to the Driver via `.collect()` guarantees an OutOfMemory (OOM) error, whereas `.show()` safely retrieves only a small subset of the data.