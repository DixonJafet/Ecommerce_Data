import sys
import boto3
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.dynamicframe import DynamicFrame
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, when, trim

# Initialize Context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Arguments
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Configuration
S3_BUCKET = "commerce-data-391738927106-us-east-2-an"
SNOWFLAKE_DB = "ecommerce_db"
SNOWFLAKE_SCHEMA = "processed_data"

# Tables to full-load
tables = [
    "customers_dataset", "geolocation_dataset", "order_items_dataset",
    "order_payments_dataset", "order_reviews_dataset", "orders_dataset",
    "products_dataset", "sellers_dataset", "product_category_name_translation"
]

job = Job(glueContext)
job.init(args['JOB_NAME'], args)

def get_snowflake_private_key():
    client = boto3.client('secretsmanager', region_name='us-east-2')
    response = client.get_secret_value(SecretId='snowflake_private_key')
    return response['SecretString']

snowflake_options = {
    "sfUrl": "rcyngph-dx14847.snowflakecomputing.com",
    "sfUser": "JAFETDIXON",
    "pem_private_key": get_snowflake_private_key(),
    "sfDatabase": SNOWFLAKE_DB,
    "sfSchema": SNOWFLAKE_SCHEMA,
    "sfWarehouse": "DATA_WH",
}

print("--- STARTING NIGHTLY FULL REFRESH ---")

# Process all 9 tables in order
for table in tables:
    print(f"Executing ETL Pipeline for: {table}")
    s3_path = f"s3://{S3_BUCKET}/raw/{table}.csv"
    
    dynamic_frame = glueContext.create_dynamic_frame.from_options(
        format_options={"withHeader": True, "separator": ","},
        connection_type="s3",
        format="csv",
        connection_options={"paths": [s3_path]}
    )
    
    df = dynamic_frame.toDF()
    
    if df.rdd.isEmpty():
        print(f"Warning: S3 file for {table} is empty. Skipping.")
        continue
        
    # Basic Cleansing: Deduplicate & drop completely empty rows
    df_cleaned = df.dropna(how="all").dropDuplicates()
    
    # Standardize empty/whitespace strings to actual SQL NULLs
    for c in df_cleaned.columns:
        df_cleaned = df_cleaned.withColumn(c, when(trim(col(c)) == "", None).otherwise(col(c)))
        
    cleaned_dyf = DynamicFrame.fromDF(df_cleaned, glueContext, f"clean_{table}")
    
    # Write to Snowflake (TRUNCATING before loading to ensure clean state)
    glueContext.write_dynamic_frame.from_options(
        frame=cleaned_dyf,
        connection_type="snowflake",
        connection_options={
            **snowflake_options,
            "dbtable": table.upper(),
            "preactions": f"TRUNCATE TABLE IF EXISTS {SNOWFLAKE_DB}.{SNOWFLAKE_SCHEMA}.{table.upper()}"
        }
    )
    print(f"Successfully refreshed table: {table}")

print("--- NIGHTLY FULL REFRESH COMPLETED SUCCESSFULLY ---")
job.commit()