terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  alias             = "s3"
  region            = var.s3_region
  access_key        = var.s3_access_key
  secret_key        = var.s3_secret_key
  s3_use_path_style = true
  endpoints {
    s3 = var.s3_endpoint
  }
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

provider "keycloak" {
  url             = var.keycloak_url
  client_id       = var.client_id
  client_secret   = var.client_secret
  realm           = var.admin_realm
  tls_skip_verify = var.tls_skip_verify
}

module "s3_bucket_create" {
  source = "../modules/common/configs/s3/bucket"
  providers = {
    aws = aws.s3
  }
  s3_bucket = var.s3_bucket
}

module "idp_realm_create" {
  source = "../modules/common/configs/idp/realm"
  providers = {
    keycloak = keycloak
  }
  realm_name = var.target_realm
}