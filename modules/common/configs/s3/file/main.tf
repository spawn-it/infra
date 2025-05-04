terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

resource "aws_s3_object" "object_creation" {
  bucket       = var.s3_bucket
  key          = var.file
  content      = var.content
  content_type = var.content_type
}