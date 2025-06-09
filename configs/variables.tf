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
}

variable "admin_user" {
  description = "Utilisateur admin Keycloak"
  type        = string
}

variable "admin_password" {
  description = "Mot de passe admin Keycloak"
  type        = string
  sensitive   = true
}

variable "realm_name" {
  description = "Nom du realm où créer les utilisateurs"
  type        = string
}

variable "keycloak_url" {
  description = "URL du serveur Keycloak"
  type        = string
}

variable "admin_realm" {
  description = "Realm d'administration (ex: master)"
  type        = string
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
}

variable "template_files" {
  description = "Liste des fichiers de template à uploader sur MinIO"
  type        = list(string)
}

