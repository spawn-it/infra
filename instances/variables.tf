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
      command    = ["server", "/data", "--console-address", ":9001"]
      has_volume = true
    }

    backend = {
      provider       = "docker"
      container_name = "spawn-it-backend"
      image          = "ghcr.io/spawn-it/backend:latest"
      ports = {
        "8000" = "8080"
      }
      env_vars = {
        "S3_URL"         = "http://localhost:9000"
        "S3_CONSOLE_URL" = "http://localhost:9001"
        "S3_ACCESS_KEY"  = "minioadmin"
        "S3_SECRET_KEY"  = "minioadmin"
        "S3_BUCKET"      = "tfstates"
      }
      command = ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
    },
    authentik = {
      provider       = "docker"
      container_name = "spawn-it-authentik"
      image          = "ghcr.io/goauthentik/server:latest"
      ports = {
        "9000" = "9002"
        "9443" = "9443"
      }
      env_vars = {
        "AUTHENTIK_SECRET_KEY"           = "change-me-secret-key"
        "AUTHENTIK_POSTGRESQL__HOST"     = "spawn-it-authentik-db"
        "AUTHENTIK_POSTGRESQL__NAME"     = "authentik"
        "AUTHENTIK_POSTGRESQL__USER"     = "authentik"
        "AUTHENTIK_POSTGRESQL__PASSWORD" = "authentik"
      }
      command = []
    },
    authentikdb = {
      provider       = "docker"
      container_name = "spawn-it-authentik-db"
      image          = "postgres:15"
      ports = {
        "5432" = "5432"
      }
      env_vars = {
        "POSTGRES_DB"       = "authentik"
        "POSTGRES_USER"     = "authentik"
        "POSTGRES_PASSWORD" = "authentik"
      }
      command    = []
      has_volume = true
    }
  }
}