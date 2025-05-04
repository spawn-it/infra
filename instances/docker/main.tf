module "docker_instance" {
  source         = "../../modules/docker/instances"
  image          = var.config.image
  container_name = var.config.container_name
  ports          = var.config.ports
  env_vars       = var.config.env_vars
  command        = var.config.command
  has_volume     = var.config.has_volume
  volume_name    = "volume-${var.config.container_name}"
  network_name   = "spawn-it-network"
}