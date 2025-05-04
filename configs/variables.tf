variable "s3_region" {
  type        = string
  default     = "us-east-1"
  description = "The region where the S3 bucket will be created"
}

variable "s3_bucket" {
  type        = string
  default     = "spawn-it-bucket"
  description = "The name of the S3 bucket to be created"
}

variable "s3_endpoint" {
  type        = string
  default     = "http://localhost:9000"
  description = "The endpoint of the S3 service"
}

variable "s3_access_key" {
  type        = string
  default     = "minioadmin"
  description = "The access key for the S3 service"
}

variable "s3_secret_key" {
  type        = string
  default     = "minioadmin"
  description = "The secret key for the S3 service"
}

variable "default_clients" {
  description = "Clients à créer par défaut avec leur UID Authentik et infos principales"
  type = map(object({
    name          = string
    email         = string
    authentik_uid = string
    created_at    = string
  }))
  default = {
    "client-a" = {
      name          = "SpawnCorp A"
      email         = "a@spawn.it"
      authentik_uid = "abc123"
      created_at    = "2025-05-04T17:00:00Z"
    },
    "client-b" = {
      name          = "SpawnCorp B"
      email         = "b@spawn.it"
      authentik_uid = "def456"
      created_at    = "2025-05-04T17:00:00Z"
    }
  }
}

