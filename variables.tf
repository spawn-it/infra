variable "s3_region"     { type = string }
variable "s3_endpoint"   { type = string }
variable "s3_access_key" { type = string }
variable "s3_secret_key" { type = string }

variable "instances" {
  description = "Defines the instances to be created"
}

variable "configs" {
  description = "Defines the configs to be created"
}