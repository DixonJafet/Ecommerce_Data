terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 1.0"
    }
  }
}
#"~> 0.87"

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Snowflake Provider
provider "snowflake" {
  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account

  user          = var.snowflake_user
  role          = "ACCOUNTADMIN"
  authenticator = "SNOWFLAKE_JWT"
  private_key   = file("private_key.pem")
  warehouse     = var.snowflake_warehouse


}

