terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.4.0"
    }
  }
}

resource "docker_image" "backend" {
  name         = var.config.image
  keep_locally = false
}

resource "docker_container" "backend" {
  name  = var.config.container_name
  image = docker_image.backend.image_id
  env = [ for k, v in var.config.env_vars : "${k}=${v}" ]

  ports {
    internal = "8000"
    external = var.config.port
  }
  
  restart = "unless-stopped"
}
