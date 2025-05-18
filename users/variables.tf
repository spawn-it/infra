variable "keycloak_url" {
  description = "URL de connexion à l'instance Keycloak"
  type        = string
  default     = "http://localhost:8080/auth"
}

variable "client_id" {
  description = "Identifiant du client OAuth dans Keycloak"
  type        = string
  default     = "spawn-it-client"
}

variable "client_secret" {
  description = "Secret du client OAuth dans Keycloak"
  type        = string
  sensitive   = true
}

variable "admin_realm" {
  description = "Nom du realm d'administration Keycloak"
  type        = string
  default     = "master"
}

variable "tls_skip_verify" {
  description = "Permet d'ignorer la vérification TLS (utile pour environnements de test)"
  type        = bool
  default     = true
}

variable "target_realm" {
  description = "Nom du realm cible dans lequel créer les utilisateurs"
  type        = string
  default     = "spawn-it-realm"
}

variable "s3_region" {
  type        = string
  description = "The region where the S3 bucket will be created"
  default     = "us-east-1"
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

