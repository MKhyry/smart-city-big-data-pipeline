# processing/spark_jobs/batch_aggregate.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, date_trunc, avg, count, round as spark_round

HDFS_RAW = "/data/smartcity/raw"
HDFS_AGG = "/data/smartcity/aggregated"

spark = SparkSession.builder.appName("SmartCityBatchAggregate").getOrCreate()
spark.sparkContext.setLogLevel("WARN")

traffic = spark.read.parquet(f"{HDFS_RAW}/traffic")
weather = spark.read.parquet(f"{HDFS_RAW}/weather")
incidents = spark.read.parquet(f"{HDFS_RAW}/incidents")

# --- Traffic x Weather impact: join by zone + hour window ---
traffic_hourly = traffic.withColumn("hour_window", date_trunc("hour", col("timestamp")))
weather_hourly = weather.withColumn("hour_window", date_trunc("hour", col("timestamp")))

traffic_weather_impact = traffic_hourly.join(
    weather_hourly,
    on=["zone_id", "hour_window"],
    how="inner"
).groupBy("zone_id", "hour_window", "condition") \
 .agg(
     spark_round(avg("avg_speed_kmh"), 2).alias("avg_speed_kmh"),
     spark_round(avg("vehicle_count"), 2).alias("avg_vehicle_count"),
     count("*").alias("record_count")
 )

traffic_weather_impact.write.mode("overwrite").parquet(f"{HDFS_AGG}/traffic_weather_impact")

# --- Incidents by zone + severity ---
incident_summary = incidents.groupBy("zone_id", "severity") \
    .agg(
        count("*").alias("incident_count"),
        spark_round(avg("response_time_minutes"), 2).alias("avg_response_time_minutes")
    )

incident_summary.write.mode("overwrite").parquet(f"{HDFS_AGG}/incident_summary")

# --- Transit summary: delay + load by route ---
transit = spark.read.parquet(f"{HDFS_RAW}/transit")

transit_summary = transit.groupBy("route_id") \
    .agg(
        spark_round(avg("delay_minutes"), 2).alias("avg_delay_minutes"),
        spark_round(avg("passenger_count"), 2).alias("avg_passenger_count"),
        count("*").alias("record_count")
    )

transit_summary.write.mode("overwrite").parquet(f"{HDFS_AGG}/transit_summary")

print("Batch aggregation complete.")
print(f"traffic_weather_impact rows: {traffic_weather_impact.count()}")
print(f"incident_summary rows: {incident_summary.count()}")
print(f"transit_summary rows: {transit_summary.count()}")

spark.stop()
