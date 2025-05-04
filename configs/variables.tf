variable "s3_region" {
  type = string
  default = "us-east-1"
  description = "The region where the S3 bucket will be created"
}

variable "s3_bucket" {
  type = string
  default = "spawn-it-bucket"
  description = "The name of the S3 bucket to be created"
}

variable "s3_endpoint" {
  type = string
  default = "http://localhost:9000"
  description = "The endpoint of the S3 service"
}

variable "s3_access_key" {
  type = string
  default = "minioadmin"
  description = "The access key for the S3 service"
}

variable "s3_secret_key" {
  type = string
  default = "minioadmin"
  description = "The secret key for the S3 service"
}