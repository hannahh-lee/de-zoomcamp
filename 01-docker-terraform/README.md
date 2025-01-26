# Module 1 Homework 

## Docker & SQL 

In this homework we'll prepare the environment and practice Docker and SQL. 

### Question 1. Understanding docker first run 

Download the Python `3.12.8` image from Docker Hub:
```bash
`docker pull python:3.12.8 `
```

Run docker with the `python:3.12.8` image in an interactive mode, use the entrypoint bash:
```bash
`docker run -it --entrypoint=bash python:3.12.8`
```

To check the version of pip inside the container, run the following command after having started the container with bash:
```bash
pip --version 
```

This will output the version of pip installed in the container: 
```bash
pip 24.3.1 from /usr/local/lib/python3.12/site-packages/pip (python 3.12)
```

### Question 2. Understanding Docker networking and docker-compose 
Given the following docker-compose.yaml, the hostname that **pgadmin** should use to connect to the postgres database is `db`. 

The `port` that **pdadmin** should connect to is `5432`.

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin  

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```

#### Prepare Postgres 

<details>
<summary>Load data to Postgres using a Dockerized script</summary> 
<br>

Run Postgres and load data:
```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz

wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
``` 

Create a network: 
```bash
docker network create pg-network
```

Postgres container on network:
```bash
docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  --network=pg-network \
  --name pg-database \
  postgres:13`
```

pgadmin container on network: 
```bash
docker run -it -d \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="password" \
    -p 8080:80 \
    --network=pg-network \
    --name pgadmin \
dpage/pgadmin4
```

Open the web browser to localhost:8080, login to pgadmin, create a new server, and connect via the credentials defined for Postgres. 

Create a Dockerfile for the python script that will ingest the CSV data into a PostgreSQL database. 

Build the Docker image. 
```bash
docker build -t nytaxidata:v001 .
```

Run the Docker container for both datasets to ingest the data.  
```yaml
docker run -it \
  --network=pg-network \
  nytaxidata:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=green_trip_data \
    --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz"
```
</details>

#### Docker Compose

<details>
<summary>Deploy the entire stack using Docker compose</summary>
<br>

Instead of running individual docker run commands for each container, the group of related containers (Postgres, pgadmin) is defined in the `docker-compose.yaml` file to make it easier to orchestrate and configure environments. 

To deploy the entire stack using Docker Compose:
```bash
docker-compose up 
```

Execute in detached mode:
```bash
docker-compose up -d
```

Stop and remove containers:
```bash 
docker-compose down
```
</details>

### Question 3. Trip Segmentation Count 
During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), there were 104838 trips up to 1 mile, 199013 between 1 (exclusive) and 3 miles (inclusive), 109645 trips between 3 (exclusive) and 7 miles (inclusive), 27688 trips between 7 (exclusive) and 10 miles (inclusive), and 35202 trips over 10 miles. 
```sql
SELECT 
  COUNT(CASE WHEN trip_distance <= 1 THEN 1 END) AS trip_count_1,
  COUNT(CASE WHEN trip_distance > 1 AND trip_distance <= 3 THEN 1 END) AS trip_count_2,
  COUNT(CASE WHEN trip_distance > 3 AND trip_distance <= 7 THEN 1 END) AS trip_count_3,
  COUNT(CASE WHEN trip_distance > 7 AND trip_distance <= 10 THEN 1 END) AS trip_count_4,
  COUNT(CASE WHEN trip_distance >= 5 THEN 1 END) AS trip_count_5
FROM 
    green_trip_data g
```

### Question 4. Longest trip for each day 
On 2019-10-11, the longest trip distance was 95.78 mi.
On 2019-10-24, the longest trip distance was 90.75 mi. 
On 2019-10-26, the longest trip distance was 91.56 mi.
On 2019-10-31, the longest trip distance was 515.89 mi.
```sql
SELECT 
	CAST(lpep_pickup_datetime AS DATE) as "day",
	COUNT(1) as "count",
	MAX(trip_distance) as "longest trip distance"
FROM 
    green_trip_data g
WHERE CAST(lpep_pickup_datetime AS DATE) in ('2019-10-11', '2019-10-24', '2019-10-26', '2019-10-31')
GROUP BY 1
ORDER by "day"
```
### Question 5. Three biggest pickup zones 
The top pickup locations with over 13,000 in `total amount` (across all trips) for 2019-10-18 were East Harlem North, East Harlem South, and Morningside Heights.
```sql
SELECT 
    CAST(lpep_pickup_datetime AS DATE) AS "day", 
    SUM(total_amount) AS "total_amount_sum", 
    zpu."Zone" AS "pick_up_loc"
FROM 
    green_trip_data g
JOIN 
    taxi_zone_lookup zpu
    ON g."PULocationID" = zpu."LocationID"
WHERE 
    CAST(lpep_pickup_datetime AS DATE) = '2019-10-18'
GROUP BY 
    CAST(lpep_pickup_datetime AS DATE), 
    zpu."Zone"
HAVING 
    SUM(total_amount) > 13000
```

### Question 6. Largest tip
The drop off zone that had the largest tip for the passengers picked up in October 2019 in the "East Harlem North" zone was JFK Airport. 
```sql
SELECT 
    MAX(tip_amount), 
    zpu."Zone" AS "pick_up_loc",
	zpd."Zone" AS "drop_off_loc"
FROM 
    green_trip_data g
LEFT JOIN 
    taxi_zone_lookup zpu
    ON g."PULocationID" = zpu."LocationID"
LEFT JOIN taxi_zone_lookup zpd
	on g."DOLocationID" = zpd."LocationID"
WHERE 
    zpu."Zone" = 'East Harlem North'
AND EXTRACT(MONTH FROM lpep_pickup_datetime) = 10
GROUP BY 2,3
ORDER BY MAX(tip_amount) desc
```

## Terraform 

### Question 7. Terraform Workflow 

The sequence for the following workflow is terraform init, terraform apply -auto-approve, terraform destroy. 

1. Downloading the provider plugins and setting up backend,
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform`

