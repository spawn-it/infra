terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.5.2"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
  }
}

provider "minio" {
  alias          = "s3"
  minio_server   = var.s3_endpoint
  minio_user     = var.s3_access_key
  minio_password = var.s3_secret_key
}

provider "keycloak" {
  alias           = "keycloak"
  url             = var.keycloak_url
  realm           = var.admin_realm
  client_id       = "admin-cli"
  username        = var.admin_user
  password        = var.admin_password
}
