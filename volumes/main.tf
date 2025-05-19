module "docker_volumes" {
  for_each = {
    for name, inst in var.volumes : name => inst
    if inst.provider == "docker"
  }
  source     = "../../modules/docker/volumes"
  volume_for = each.value.volume_for
}