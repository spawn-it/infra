module "docker_volume" {
  source     = "../../modules/volumes/docker"
  volume_for = var.config.volume_for
}
