terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
  }
}

resource "keycloak_openid_client" "react_client" {
  realm_id                     = var.realm_id
  client_id                    = "myclient"
  name                         = "React Frontend"
  enabled                      = true
  access_type                  = "PUBLIC"
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
  root_url                     = "http://localhost:3000"
  valid_redirect_uris          = ["http://localhost:3000/*"]
  web_origins                  = ["http://localhost:3000"]
  pkce_code_challenge_method   = "S256"
}