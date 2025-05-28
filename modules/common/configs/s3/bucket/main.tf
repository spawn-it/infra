terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.5.2"
    }
  }
}

resource "minio_s3_bucket" "bucket" {
  bucket        = var.s3_bucket
  force_destroy = true
}