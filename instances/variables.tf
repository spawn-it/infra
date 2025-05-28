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