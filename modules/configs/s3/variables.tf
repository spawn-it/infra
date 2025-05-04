variable "s3_endpoint" {
  description = "S3-compatible endpoint URL (e.g., http://localhost:9000)"
  type        = string
}

variable "s3_bucket" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "s3_region" {
  description = "Region to use with the S3-compatible service"
  type        = string
}

variable "s3_access_key" {
  description = "Access key for the S3-compatible service"
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "Secret key for the S3-compatible service"
  type        = string
  sensitive   = true
}
