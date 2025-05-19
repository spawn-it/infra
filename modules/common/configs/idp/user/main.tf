terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
  }
}

resource "keycloak_user" "user" {
  realm_id   = var.realm_id
  username   = var.user.username
  email      = var.user.email
  first_name = var.user.first_name
  last_name  = var.user.last_name
  enabled    = var.user.enabled
  initial_password {
    value     = var.user.password
    temporary = false
  }
}