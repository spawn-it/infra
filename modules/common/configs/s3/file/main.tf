terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.5.2"
    }
  }
}

resource "minio_s3_object" "object_creation_filo" {
  bucket_name  = var.s3_bucket
  object_name  = var.file
  source       = var.file_path
  content_type = var.content_type
}