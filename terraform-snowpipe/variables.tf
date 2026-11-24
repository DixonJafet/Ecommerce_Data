variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "bucket_name" {
  description = "S3 bucket name"
  default     = "commerce-data-391738927106-us-east-2-an"
}

variable "snowflake_account" {
  description = "Snowflake account identifier"
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_private_key_path" {
  description = "Path to Snowflake private key"
  type        = string
}

variable "snowflake_database" {
  description = "Snowflake database"
  default     = "ecommerce_db"
}

variable "snowflake_schema" {
  description = "Snowflake schema"
  default     = "processed_data"
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse"
  default     = "data_wh"
  type        = string
}

variable "snowflake_organization" {
  description = "Snowflake organization name"
  type        = string
}

variable "tables" {
  description = "List of tables and their CSV files"
  default     = [
    "customers_dataset",
    "geolocation_dataset",
    "order_items_dataset",
    "order_payments_dataset",
    "order_reviews_dataset",
    "orders_dataset",
    "products_dataset",
    "sellers_dataset",
    "product_category_name_translation"
  ]
}