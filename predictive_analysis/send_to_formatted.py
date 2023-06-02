import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from pyspark.sql import SQLContext
from pyspark.sql import Row
import pyspark.sql.functions as fn
from pyspark.conf import SparkConf
from pyspark.sql.types import LongType, StringType, StructField, StructType, BooleanType, ArrayType, IntegerType


def write_toPostgres(df, table_name, schema=None):
    if schema == None:
        df.write.format("jdbc")\
            .option("url", "jdbc:postgresql://localhost:5432/bdm_joint")\
            .option("driver", "org.postgresql.Driver").option("dbtable", table_name)\
            .option("user", "bdm").option("password", "test123")\
            .option("driver", "org.postgresql.Driver")\
            .save()
    else:
        df.write.format("jdbc")\
            .option("url", "jdbc:postgresql://localhost:5432/bdm_joint")\
            .option("driver", "org.postgresql.Driver").option("dbtable", table_name)\
            .option("user", "bdm").option("password", "test123")\
            .option("driver", "org.postgresql.Driver")\
            .option("customSchema", schema)\
            .save()

sc = SparkSession.builder\
    .config("spark.jars", "/home/sayyor/postgresql-42.6.0.jar")\
    .config("spark.driver.extraClassPath", "/home/sayyor/postgresql-42.6.0.jar")\
    .config("spark.executor.extraClassPath", "/home/sayyor/postgresql-42.6.0.jar")\
    .getOrCreate()
sqlContext = SQLContext(sc)

# Joining addresses with users
users = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/users.parquet", header='true', inferSchema='true')
users = users.withColumn('dob', fn.to_date(fn.col("dob"),"yyyy.M.d"))
addresses = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/addresses.parquet", header='true', inferSchema='true')

result = users.join(addresses, users.user_id == addresses.id).drop(
        "Unnamed: 0", "id", "firstname", "lastname", "mobile", "streetNumber",
        "buildingNumber", "postalCode", "provence", "country", "streetName"
    )

result = result.withColumn("city", fn.when(fn.col("city") == 'Palma de Mallorca', 'Palma').otherwise(fn.col("city")))
write_toPostgres(result, "users")


# Estimating Gas Price for each City Distance
city_dist = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/cities_distances.parquet", header='true', inferSchema='true')

city_dist = city_dist.withColumn("name1", fn.when(fn.col("name1") == 'Alacant / Alicante', 'Alacant').otherwise(fn.col("name1")))
city_dist = city_dist.withColumn("name2", fn.when(fn.col("name2") == 'Alacant / Alicante', 'Alacant').otherwise(fn.col("name2")))

city_dist = city_dist.drop("latitude1", "longitude1", "latitude2", "longitude2")

gas = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/gas.parquet", header='true', inferSchema='true')

city_dist = city_dist.join(gas, city_dist.country1 == gas.country)

city_dist = city_dist.withColumn("lpg_price", city_dist["lpg"]*(city_dist['distance_km']/100)*8)
city_dist = city_dist.withColumn("diesel_price", city_dist["diesel"]*(city_dist['distance_km']/100)*5)
city_dist = city_dist.withColumn("gasoline_price", city_dist["gasoline"]*(city_dist['distance_km']/100)*6.3)

city_dist = city_dist.drop("country", "gasoline", "diesel", "lpg", "Unnamed: 0")
write_toPostgres(city_dist, "city_distances")

# Scheduled Flights Table
flights = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/scheduledFlights.parquet", header='true', inferSchema='true')
flights = flights.withColumn('departureTime', fn.to_timestamp(fn.col("departureTime"),"yyyy-MM-dd'T'HH:mm:ss.SSS"))
flights = flights.withColumn('arrivalTime', fn.to_timestamp(fn.col("arrivalTime"),"yyyy-MM-dd'T'HH:mm:ss.SSS"))
flights = flights.withColumn('flightNumber', flights.flightNumber.cast('string'))
flights = flights.withColumn('departureTerminal', flights.departureTerminal.cast('int'))
flights = flights.withColumn('arrivalTerminal', flights.arrivalTerminal.cast('int'))

write_toPostgres(flights, "flights")


# Changing airport codes to the cities they are located in for easier matching with other tables
travels = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/travels.parquet", header='true', inferSchema='true')

travels = travels.withColumn("departureAirportFsCode",
                    fn.when(fn.col("departureAirportFsCode") == 'MAD', 'Madrid')
                    .otherwise(fn.when(fn.col("departureAirportFsCode") == 'BCN', 'Barcelona')
                    .otherwise(fn.when(fn.col("departureAirportFsCode") == 'PMI', 'Palma')
                    .otherwise(fn.when(fn.col("departureAirportFsCode") == 'AGP', 'Málaga')
                    .otherwise(fn.col("departureAirportFsCode"))))))
travels = travels.withColumn("arrivalAirportFsCode",
                    fn.when(fn.col("arrivalAirportFsCode") == 'MAD', 'Madrid')
                    .otherwise(fn.when(fn.col("arrivalAirportFsCode") == 'BCN', 'Barcelona')
                    .otherwise(fn.when(fn.col("arrivalAirportFsCode") == 'PMI', 'Palma')
                    .otherwise(fn.when(fn.col("arrivalAirportFsCode") == 'AGP', 'Málaga')
                    .otherwise(fn.col("arrivalAirportFsCode"))))))
travels = travels.withColumn('departureTime', fn.to_timestamp(fn.col("departureTime"),"yyyy-MM-dd HH:mm:ss"))
travels = travels.withColumn('arrivalTime', fn.to_timestamp(fn.col("arrivalTime"),"yyyy-MM-dd HH:mm:ss"))
write_toPostgres(travels, "travels")


# Products Table
products = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/products.parquet", header='true', inferSchema='true')
products = products.drop("product_image_link")
write_toPostgres(products, "products")


# # DHL price/zone
dhl_price = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/DHL_Price.parquet", header='true', inferSchema='true')
dhl_zone = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/DHL_Zone.parquet", header='true', inferSchema='true')

dhl_zone = dhl_zone.withColumn("Region_start", fn.when(fn.col("Region_start") == 'Palma De Mallorca (PMI)', 'Palma').otherwise(fn.col("Region_start")))
dhl_zone = dhl_zone.withColumn("Region_end", fn.when(fn.col("Region_end") == 'Palma De Mallorca (PMI)', 'Palma').otherwise(fn.col("Region_end")))

# Replacing Rest of Spain with our 3 cities
dhl_zone_new = dhl_zone.withColumn("Region_start", fn.when(fn.col("Region_start") == "Resto de España (ES)", "Málaga").otherwise(fn.col("Region_start")))
dhl_zone_new = dhl_zone_new.union(dhl_zone.withColumn("Region_start", fn.when(fn.col("Region_start") == "Resto de España (ES)", "Barcelona").otherwise(fn.col("Region_start"))))
dhl_zone_new = dhl_zone_new.union(dhl_zone.withColumn("Region_start", fn.when(fn.col("Region_start") == "Resto de España (ES)", "Madrid").otherwise(fn.col("Region_start"))))

dhl_zone = dhl_zone_new.withColumn("Region_end", fn.when(fn.col("Region_end") == "Resto de España (ES)", "Málaga").otherwise(fn.col("Region_end")))
dhl_zone = dhl_zone.union(dhl_zone_new.withColumn("Region_end", fn.when(fn.col("Region_end") == "Resto de España (ES)", "Barcelona").otherwise(fn.col("Region_end"))))
dhl_zone = dhl_zone.union(dhl_zone_new.withColumn("Region_end", fn.when(fn.col("Region_end") == "Resto de España (ES)", "Madrid").otherwise(fn.col("Region_end"))))
write_toPostgres(dhl_zone, "dhl_zone")
write_toPostgres(dhl_price, "dhl_price")

# Adding the cities of the addresse for each request
requests = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/requests.parquet", header='true', inferSchema='true')
requests = requests.withColumn('dateToDeliver', fn.to_timestamp(fn.col("dateToDeliver"),"MM/dd/yyyy hh:mm a"))
requests = requests.withColumn('dateDelivered', fn.to_timestamp(fn.col("dateDelivered"),"MM/dd/yyyy hh:mm a"))
requests = requests.withColumn('requestDate', fn.to_timestamp(fn.col("requestDate"),"MM/dd/yyyy hh:mm a"))
requests = requests.withColumn('travellerId', requests.travellerId.cast('int'))

requests = requests.drop("description")
write_toPostgres(requests, "requests")

# requests = requests.join(result, result.address == requests.pickUpAddress)
# requests = requests.withColumnRenamed("city", 'pickupCity').drop("address")
# requests = requests.join(result, result.address == requests.collectionAddress)
# requests = requests.withColumnRenamed("city", 'collectCity')

# # Adding the DHL Zone for each request based on Collect and Pickup Cities
# requests = requests.join(dhl_zone, (dhl_zone.Region_start == requests.collectCity) & (dhl_zone.Region_end == requests.pickupCity))
# requests = requests.drop("Region_start", "Region_end", "address")

# # Adding the products weights
# products = products.drop("product_length_cm", "product_height_cm", "product_width_cm", "product_category_name_english", "product_name")
# requests = requests.join(products, products.product_id == requests.productId)
# requests = requests.drop("product_id")