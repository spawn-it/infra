variable "keycloak_url" {
  description = "URL du serveur Keycloak"
  type        = string
}

variable "client_id" {
  description = "Client ID pour Terraform dans Keycloak"
  type        = string
}

variable "client_secret" {
  description = "Secret du client Terraform"
  type        = string
  sensitive   = true
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
}

variable "create_realm" {
  description = "Créer le realm s'il n'existe pas"
  type        = bool
  default     = true
}

variable "users" {
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