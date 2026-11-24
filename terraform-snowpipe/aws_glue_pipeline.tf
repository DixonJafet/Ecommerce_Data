# 1. Reference your existing S3 bucket
data "aws_s3_bucket" "commerce_data" {
  bucket = var.bucket_name
}

# ==========================================
# AWS GLUE WORKFLOW & JOB RESOURCES
# ==========================================

resource "aws_glue_workflow" "ecommerce_workflow" {
  name = "ecommerce-s3-to-snowflake-workflow"
}

resource "aws_glue_job" "ecommerce_etl" {
  name     = "ecommerce-s3-to-snowflake"
  role_arn = aws_iam_role.glue_service_role.arn

  command {
    script_location = "s3://aws-glue-assets-391738927106-us-east-2/scripts/data_cleaning.py"
    python_version  = "3"
  }

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  
  default_arguments = {
    "--job-language" = "python"
    "--extra-jars"   = "s3://aws-glue-assets-391738927106-us-east-2/jars/snowflake-jdbc-3.13.30.jar,s3://aws-glue-assets-391738927106-us-east-2/jars/spark-snowflake_2.12-2.12.0-spark_3.3.jar"
  }
}

# ==========================================
# NATIVE SCHEDULED TRIGGER (10:00 PM Costa Rica Local / 4:00 AM UTC)
# ==========================================

resource "aws_glue_trigger" "ecommerce_scheduled_trigger" {
  name          = "ecommerce-scheduled-nightly-trigger"
  type          = "SCHEDULED"
  
  # AWS schedules run in UTC. Costa Rica is UTC-6. 
  # 10:00 PM Costa Rica time = 04:00 AM UTC (next day).
  schedule      = "cron(0 4 * * ? *)" 
  
  workflow_name = aws_glue_workflow.ecommerce_workflow.name
  
  # Automatically start this trigger upon creation
  start_on_creation = true

  actions {
    job_name = aws_glue_job.ecommerce_etl.name
  }
}

# ==========================================
# IAM ROLES & POLICIES
# ==========================================

resource "aws_iam_role" "glue_service_role" {
  name = "ecommerce_glue_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_basic" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# S3 Access Policy
resource "aws_iam_role_policy" "glue_s3_access" {
  name = "glue_s3_read_access"
  role = aws_iam_role.glue_service_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        data.aws_s3_bucket.commerce_data.arn,
        "${data.aws_s3_bucket.commerce_data.arn}/*",
        "arn:aws:s3:::aws-glue-assets-391738927106-us-east-2",
        "arn:aws:s3:::aws-glue-assets-391738927106-us-east-2/*"
      ]
    }]
  })
}

# Secrets Manager Access Policy
resource "aws_iam_role_policy" "glue_secrets_access" {
  name = "glue_secrets_read_access_v2" 
  role = aws_iam_role.glue_service_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = "arn:aws:secretsmanager:us-east-2:391738927106:secret:snowflake_private_key*"
    }]
  })
}