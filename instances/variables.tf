variable "instances" {
  description = "Map of container instance configurations"
  type = map(object({
    provider       = string
    container_name = string
    image          = string
    ports          = map(string)
    env_vars       = map(string)
    command        = list(string)
    has_volume     = optional(bool, false)
    network_name   = string
  }))
  default = {
    s3 = {
      provider       = "docker"
      container_name = "spawn-it-s3"
      image          = "quay.io/minio/minio:latest"
      ports = {
        "9000" = "9000"
        "9001" = "9001"
      }
      env_vars = {
        "MINIO_ROOT_USER"     = "minioadmin"
        "MINIO_ROOT_PASSWORD" = "minioadmin"
      }
      command      = ["server", "/data", "--console-address", ":9001"]
      has_volume   = true
      network_name = "spawn-it-network"
    }

    backend = {
      provider       = "docker"
      container_name = "spawn-it-backend"
      image          = "ghcr.io/spawn-it/backend:latest"
      ports = {
        "8000" = "8000"
      }
      env_vars = {
        "S3_URL"         = "http://spawn-it-s3:9000"
        "S3_CONSOLE_URL" = "http://spawn-it-s3:9001"
        "S3_REGION"      = "us-east-1"
        "S3_ACCESS_KEY"  = "minioadmin"
        "S3_SECRET_KEY"  = "minioadmin"
        "S3_BUCKET"      = "spawn-it-bucket"
      }
      command      = ["npm", "run", "start"]
      network_name = "spawn-it-network"
    },

    frontend = {
      provider       = "docker"
      container_name = "spawn-it-frontend"
      image          = "ghcr.io/spawn-it/frontend:latest"
      ports = {
        "3000" = "3000"
      }
      env_vars = {
        "KEYCLOAK_URL"          = "http://spawn-it-keycloak:8080"
        "KEYCLOAK_REALM"        = "spawn-it-realm"
        "KEYCLOAK_CLIENT_ID"    = "spawn-it-client"
        "KEYCLOAK_SCOPE"        = "openid profile email"
        "KEYCLOAK_REDIRECT_URI" = "http://localhost:3000/callback"
      }
      command      = ["npm", "run", "start"]
      network_name = "spawn-it-network"
    },

    keycloak = {
      provider       = "docker"
      container_name = "spawn-it-keycloak"
      image          = "quay.io/keycloak/keycloak:24.0.1"
      ports = {
        "8080" = "8080"
      }
      env_vars = {
        "KEYCLOAK_ADMIN"          = "admin"
        "KEYCLOAK_ADMIN_PASSWORD" = "admin"
      }
      command      = ["start-dev"]
      network_name = "spawn-it-network"
    }
  }
}