terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "docker_image" "instance" {
  name         = var.image
  keep_locally = false
}

resource "null_resource" "check_volume_exists" {
  count = var.has_volume ? 1 : 0
  provisioner "local-exec" {
    command = "docker volume inspect ${var.volume_name} > /dev/null 2>&1 || (echo \"Docker volume '${var.volume_name}' does not exist\" && exit 1)"
  }
}


resource "docker_container" "instance" {
  depends_on = [null_resource.check_volume_exists]
  name       = var.container_name
  image      = docker_image.instance.image_id
  env        = [for k, v in var.env_vars : "${k}=${v}"]
  command    = var.command

  dynamic "ports" {
    for_each = var.ports
    content {
      internal = tonumber(ports.key)
      external = tonumber(ports.value)
    }
  }

  dynamic "volumes" {
    for_each = var.has_volume ? [1] : []
    content {
      volume_name    = var.volume_name
      container_path = "/data"
      read_only      = false
    }
  }
  network_mode = "bridge"
  networks_advanced {
    name = "bridge"
  }
  restart = "unless-stopped"
}
