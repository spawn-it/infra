terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

resource "aws_s3_object" "folder" {
  bucket       = var.s3_bucket
  key          = "${var.folder_name}/"
  content_type = "application/x-directory"
  content      = ""
}