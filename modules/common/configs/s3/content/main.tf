terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.5.2"
    }
  }
}

resource "minio_s3_object" "object_creation" {
  provider     = minio.s3
  bucket       = var.s3_bucket
  key          = var.file
  content      = var.content
  content_type = var.content_type
}