terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
  }
}

# Configure the Keycloak provider
provider "keycloak" {
  url             = var.keycloak_url
  client_id       = var.client_id
  client_secret   = var.client_secret
  realm           = var.admin_realm
  tls_skip_verify = var.tls_skip_verify
}

# Création du realm si nécessaire
resource "keycloak_realm" "realm" {
  count   = var.create_realm ? 1 : 0
  realm   = var.target_realm
  enabled = true
}

# ID du realm, créé ou existant
locals {
  realm_id = var.create_realm ? keycloak_realm.realm[0].id : var.target_realm
}

# Création des utilisateurs dans le realm
resource "keycloak_user" "users" {
  for_each = { for u in var.users : u.username => u }

  realm_id   = local.realm_id
  username   = each.value.username
  email      = each.value.email
  first_name = each.value.first_name
  last_name  = each.value.last_name
  enabled    = each.value.enabled
}

# Définition des mots de passe
resource "keycloak_user_credentials" "passwords" {
  for_each = keycloak_user.users

  realm_id  = local.realm_id
  user_id   = each.value.id
  type      = "password"
  value     = var.users[index(var.users.*.username, each.key)].password
  temporary = false
}