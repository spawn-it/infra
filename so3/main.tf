terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.4.0"
    }
  }
}

resource "docker_image" "minio" {
  name         = var.config.image
  keep_locally = false
}

resource "docker_container" "minio" {
  name  = var.config.container_name
  image = docker_image.minio.image_id
    command = [
    "server",
    "/data",
    format("--console-address=:%d", var.config.console_port)
    ]
  env = [ for k, v in var.config.env_vars : "${k}=${v}" ]

  ports {
    internal = var.config.port
    external = var.config.port
  }

  ports {
    internal = var.config.console_port
    external = var.config.console_port
  }
}
