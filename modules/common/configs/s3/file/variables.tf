variable "file" {
  description = "File to create in S3"
  type        = string
}

variable "s3_bucket" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "content" {
  description = "Content of the file to create in S3"
  type        = string
}

variable "content_type" {
  description = "Content type of the file to create in S3"
  type        = string
}