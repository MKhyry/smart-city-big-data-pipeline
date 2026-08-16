# processing/spark_jobs/stream_ingest_to_hdfs.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StructType, StringType, DoubleType, IntegerType, TimestampType

KAFKA_SERVERS = "localhost:9092"
HDFS_RAW = "/data/smartcity/raw"
HDFS_CHECKPOINT = "/data/smartcity/checkpoints"

spark = SparkSession.builder.appName("SmartCityStreamIngest").getOrCreate()
spark.sparkContext.setLogLevel("WARN")

traffic_schema = StructType() \
    .add("zone_id", StringType()) \
    .add("congestion_level", StringType()) \
    .add("vehicle_count", IntegerType()) \
    .add("avg_speed_kmh", DoubleType()) \
    .add("timestamp", TimestampType())

weather_schema = StructType() \
    .add("zone_id", StringType()) \
    .add("temperature_c", DoubleType()) \
    .add("condition", StringType()) \
    .add("timestamp", TimestampType())

transit_schema = StructType() \
    .add("route_id", StringType()) \
    .add("scheduled_time", TimestampType()) \
    .add("actual_time", TimestampType()) \
    .add("delay_minutes", DoubleType()) \
    .add("passenger_count", IntegerType()) \
    .add("timestamp", TimestampType())

incident_schema = StructType() \
    .add("incident_id", StringType()) \
    .add("type", StringType()) \
    .add("zone_id", StringType()) \
    .add("response_time_minutes", DoubleType()) \
    .add("severity", StringType()) \
    .add("timestamp", TimestampType())

def read_topic(topic):
    return spark.readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", KAFKA_SERVERS) \
        .option("subscribe", topic) \
        .option("startingOffsets", "latest") \
        .load()

def parse(df, schema):
    return df.selectExpr("CAST(value AS STRING) AS json_str") \
        .select(from_json(col("json_str"), schema).alias("data")) \
        .select("data.*")

def write_stream(df, name):
    return df.writeStream \
        .format("parquet") \
        .option("path", f"{HDFS_RAW}/{name}") \
        .option("checkpointLocation", f"{HDFS_CHECKPOINT}/{name}") \
        .outputMode("append") \
        .start()

traffic_df = parse(read_topic("smartcity-traffic"), traffic_schema)
weather_df = parse(read_topic("smartcity-weather"), weather_schema)
transit_df = parse(read_topic("smartcity-transit"), transit_schema)
incident_df = parse(read_topic("smartcity-incidents"), incident_schema)

q1 = write_stream(traffic_df, "traffic")
q2 = write_stream(weather_df, "weather")
q3 = write_stream(transit_df, "transit")
q4 = write_stream(incident_df, "incidents")

spark.streams.awaitAnyTermination()
