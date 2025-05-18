terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.5.2"
    }
  }
}

resource "minio_s3_object" "folder" {
  bucket_name  = var.s3_bucket
  object_name  = "${var.folder_name}/ "
  content_type = "application/x-directory"
  content      = " "
}