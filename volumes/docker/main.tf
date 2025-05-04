module "docker_volume" {
  source     = "../../modules/docker/volumes"
  volume_for = var.config.volume_for
}
