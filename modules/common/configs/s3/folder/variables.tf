variable "folder_name" {
  description = "Nom du dossier à créer"
  type        = string
}

variable "s3_bucket" {
  type        = string
  default     = "spawn-it-bucket"
  description = "The name of the S3 bucket to be created"
}
