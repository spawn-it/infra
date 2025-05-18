terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
  }
}

resource "keycloak_realm" "my_realm" {
  realm   = var.realm_name
  enabled = true
}
