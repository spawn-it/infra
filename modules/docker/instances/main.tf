terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# Pull the Docker image specified by the 'image' variable
resource "docker_image" "instance" {
  name         = var.image
  keep_locally = false # Do not retain the image locally after container removal
}

# Check if the specified Docker volume exists before container creation
resource "null_resource" "check_volume_exists" {
  # Only run if a volume is required
  count = var.has_volume ? 1 : 0

  provisioner "local-exec" {
    command = "docker volume inspect ${var.volume_name} > /dev/null 2>&1 || (echo \"Docker volume '${var.volume_name}' does not exist\" && exit 1)"
  }
}

# Look up an existing Docker network
data "docker_network" "custom_network" {
  name = "spawn-it-net"
}

# Create the Docker container
resource "docker_container" "instance" {
  depends_on = [null_resource.check_volume_exists] # Explicit dependency on volume check

  name    = var.container_name
  image   = docker_image.instance.image_id
  env     = [for k, v in var.env_vars : "${k}=${v}"]
  command = var.command

  # Configure port mappings between host and container
  dynamic "ports" {
    for_each = var.ports # Expected format: { "container_port" = "host_port" }
    content {
      internal = tonumber(ports.key)
      external = tonumber(ports.value)
    }
  }

  # Mount the volume if 'has_volume' is true
  dynamic "volumes" {
    for_each = var.has_volume ? [1] : []
    content {
      volume_name    = var.volume_name
      container_path = "/data"
      read_only      = false
    }
  }

  # Attach container to the specified Docker network
  networks_advanced {
    name = data.docker_network.custom_network.name
  }

  lifecycle {
    # Prevent unnecessary container recreation due to minor diffs
    #
    # Docker may return some attributes (like 'command', 'ports', 'network_mode')
    # with defaults or different formatting than the Terraform config.
    # The Docker provider compares these via 'docker inspect' and might trigger
    # recreation even if the behavior is unchanged.
    #
    # We ignore those fields to avoid unexpected restarts.
    # NOTE: Changes to these fields won't be applied unless 'ignore_changes' is removed
    # or you force recreation (e.g., using 'terraform taint').
    ignore_changes = [network_mode, ports, command]
  }

  restart = "unless-stopped"
}
