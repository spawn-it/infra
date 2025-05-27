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
  default     = "localhost:9000"
  description = "The endpoint of the S3 service"
}

variable "s3_access_key" {
  type        = string
  default     = "minioadmin"
  description = "The access key for the S3 service"
}

variable "s3_secret_key" {
  description = "The secret key for the S3 service"
  type        = string
  default     = "minioadmin"
}

variable "admin_user" {
  description = "Utilisateur admin Keycloak"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Mot de passe admin Keycloak"
  type        = string
  sensitive   = true
  default     = "admin"
}


variable "realm_name" {
  description = "Nom du realm où créer les utilisateurs"
  type        = string
  default     = "spawn-it-realm"
}

variable "keycloak_url" {
  description = "URL du serveur Keycloak"
  type        = string
  default     = "http://localhost:8080"
}

variable "admin_realm" {
  description = "Realm d'administration (ex: master)"
  type        = string
  default     = "master"
}

variable "tls_skip_verify" {
  description = "Skip TLS verification si certificat auto-signé"
  type        = bool
  default     = true
}

variable "target_realm" {
  description = "Nom du realm où créer les utilisateurs"
  type        = string
  default     = "spawn-it-realm"
}

variable "create_realm" {
  description = "Créer le realm s'il n'existe pas"
  type        = bool
  default     = true
}

variable "default_users" {
  description = "Liste des utilisateurs à créer"
  type = list(object({
    username   = string
    email      = string
    first_name = string
    last_name  = string
    enabled    = bool
    password   = string
  }))
  default = [
    {
      username   = "alice.dubois"
      email      = "alice.dubois@spawn.it"
      first_name = "Alice"
      last_name  = "Dubois"
      enabled    = true
      password   = "ChangeMe123!"
    },
    {
      username   = "bob.martin"
      email      = "bob.martin@spawn.it"
      first_name = "Bob"
      last_name  = "Martin"
      enabled    = true
      password   = "ChangeMe123!"
    },
    {
      username   = "charlie.dupont"
      email      = "charlie.dupont@spawn.it"
      first_name = "Charlie"
      last_name  = "Dupont"
      enabled    = true
      password   = "ChangeMe123!"
    }
  ]
}

