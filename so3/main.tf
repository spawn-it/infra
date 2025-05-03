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
  keep_locally = true
}

resource "docker_container" "minio" {
  name  = "minio"
  image = docker_image.minio.image_id

  env = [
    "MINIO_ROOT_USER=${var.config.root_user}",
    "MINIO_ROOT_PASSWORD=${var.config.root_password}"
  ]

  ports {
    internal = 9000
    external = var.config.api_port
  }

  ports {
    internal = 9001
    external = var.config.console_port
  }

  command = ["server", var.config.volume_path, "--console-address", ":9001"]
}
