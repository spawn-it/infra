terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.4.0"
    }
  }
}

resource "docker_image" "instance" {
  name         = var.config.image
  keep_locally = false
}

resource "docker_container" "instance" {
  name  = var.config.container_name
  image = docker_image.instance.image_id
  env = [ for k, v in var.config.env_vars : "${k}=${v}" ]
  command = var.config.command

  dynamic "ports" {
    for_each = var.config.ports
    content {
      internal = tonumber(ports.key)
      external = tonumber(ports.value)
    }
  }

  dynamic "mounts" {
    for_each = try(var.config.volume.type == "volume", false) ? [var.config.volume] : []
    content {
      type   = "volume"
      source = mounts.value.source
      target = mounts.value.container_path
      read_only = false
    }
  }
  
  restart = "unless-stopped"

}