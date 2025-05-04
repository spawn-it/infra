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

module "s3_bucket_create" {
  source = "../modules/common/configs/s3/bucket"
  providers = {
    aws = aws.s3
  }
  s3_bucket = var.s3_bucket
}

module "s3_client_files" {
  source = "../modules/common/configs/s3/file"

  providers = {
    aws = aws.s3
  }

  for_each     = var.default_clients
  s3_bucket    = var.s3_bucket
  file         = "clients/${each.key}/meta.json"
  content_type = "application/json"

  content = jsonencode({
    client_id     = each.key
    name          = each.value.name
    email         = each.value.email
    authentik_uid = each.value.authentik_uid
    created_at    = each.value.created_at
  })

  depends_on = [module.s3_bucket_create]
}