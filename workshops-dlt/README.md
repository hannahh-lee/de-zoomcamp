# Workshop - dlt

## Question 1 - dlt 

Install dlt:
```bash
pip install "dlt[duckdb] 
``` 

Check dlt version:
```bash 
dlt --version 
``` 

The dlt version is 1.6.1.

## Question 2: Define and Run the Pipeline (NYC Taxi API)

We can use dlt to extract data from the NYC Taxi API, taking advantage of their built-in REST API Client. We will use the `@dlt.resource` decorator which denotes a logical grouping of data within a data source, typically holding data of similar structure and origin. 

Create a new virtual env:
```bash
python -m venv ./env
```

Activate the virtual environment:
```bash
source ./env/bin/activate
```

Install `dlt` in the virtual env:
```bash
pip install "dlt[duckdb]"
```

Run `dlt_pipeline.py` to extract all pages of data from the NYC Taxi API, load the data into DuckDB, and explore the resulting dataset.
```bash
python dlt_pipeline.py 
``` 

A total of 4 tables were created.

## Question 3: Explore the loaded data 

When inspecting the `rides` table, 10000 records were extracted. 

## Question 4: Trip Duration Analysis

The average trip duration was 12.3049. 



