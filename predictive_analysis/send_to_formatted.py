import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from pyspark.sql import SQLContext
from pyspark.sql import Row
import pyspark.sql.functions as fn
from pyspark.conf import SparkConf

sc = SparkSession.builder\
    .config("spark.jars", "/home/sayyor/postgresql-42.6.0.jar")\
    .config("spark.driver.extraClassPath", "/home/sayyor/postgresql-42.6.0.jar")\
    .config("spark.executor.extraClassPath", "/home/sayyor/postgresql-42.6.0.jar")\
    .getOrCreate()
sqlContext = SQLContext(sc)

users = sqlContext.read.format("parquet").load("hdfs://localhost:9900/input/users.parquet", header='true', inferSchema='true')

users.drop("Unnamed: 0").write.format("jdbc")\
    .option("url", "jdbc:postgresql://localhost:5432/bdm_joint")\
    .option("driver", "org.postgresql.Driver").option("dbtable", "users")\
    .option("user", "bdm").option("password", "test123")\
    .option("driver", "org.postgresql.Driver").save()