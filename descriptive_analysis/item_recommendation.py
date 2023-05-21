import os
import pandas as pd
from pyspark.sql import SparkSession
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, when
import itertools

# Initialize Spark Session
spark = SparkSession.builder.appName('read_parquet').getOrCreate()

current_dir = os.getcwd()

file_path_product = os.path.join(current_dir, "sample_output/products.parquet")
file_path_requests = os.path.join(current_dir, "sample_output/requests.parquet")
file_path_travels = os.path.join(current_dir, "sample_output/travels.parquet")
file_path_users = os.path.join(current_dir, "sample_output/users.parquet")

# Read the Parquet file
product = spark.read.parquet(file_path_product)

requests_pd = pd.read_parquet(file_path_requests)
requests_pd = requests_pd.rename(columns={"Unnamed: 0": "requestID"})
requests = spark.createDataFrame(requests_pd)

travels_pd = pd.read_parquet(file_path_travels)
travels_pd = travels_pd.rename(columns={"Unnamed: 0": "travelID"})
travels = spark.createDataFrame(travels_pd)

users = spark.read.parquet(file_path_users)

# Print the schema
product.printSchema()
requests.printSchema()
travels.printSchema()
users.printSchema()

# Show the DataFrame
# product.show()
# requests.show()
# travels.show()
# users.show()

# Map the airport codes to city names in the travels DataFrame
airport_to_city = {
    "MAD": "Madrid",
    "BCN": "Alacant / Alicante",
    "AGP": "Málaga",
    "PMI": "Palma"
}

for code, city in airport_to_city.items():
    travels = travels.withColumn("departureAirportFsCode", when(col("departureAirportFsCode") == code, city).otherwise(col("departureAirportFsCode")))
    travels = travels.withColumn("arrivalAirportFsCode", when(col("arrivalAirportFsCode") == code, city).otherwise(col("arrivalAirportFsCode")))


product_requests = product.join(requests, "product_id")
travel_requests = product_requests.join(travels, (product_requests.fromCity == travels.departureAirportFsCode) & 
                                                 (product_requests.toCity == travels.arrivalAirportFsCode))

def find_combinations(items):
    # Generate all combinations of products
    for r in range(1, len(items) + 1):
        for combination in itertools.combinations(items, r):
            yield combination

travel_requests_pd = travel_requests.toPandas()

groups = travel_requests_pd.groupby('travelID')

results = []
for travel_id, group in groups:
    items = list(zip(group['product_weight_g'].tolist(), group['product_name'].tolist()))
    extra_luggage = group['extraLuggage'].iloc[0] * 1000  # convert kg to g
    
    # Find combinations of products that weigh less than or equal to the extra luggage weight
    for combination in find_combinations(items):
        # Calculate total weight of the combination
        total_weight = sum([item[0] for item in combination])
        if total_weight <= extra_luggage:
            results.append({
                'travelID': travel_id,
                'product_weights': [item[0] for item in combination],
                'product_names': [item[1] for item in combination],
                'total_weight': total_weight,
                'extra_luggage': extra_luggage
            })

results_df = pd.DataFrame(results)
print(results_df)