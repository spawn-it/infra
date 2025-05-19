# Module used to dispatch docker instances to the module in charge of creating the docker instances
module "docker_instances" {
  # We check his provider to know if we need to use the docker module
  for_each = {
    for name, inst in var.instances : name => inst
    if inst.provider == "docker"
  }
  source         = "../../modules/docker/instances"
  image          = each.value.image
  container_name = each.value.container_name
  ports          = each.value.ports
  env_vars       = each.value.env_vars
  command        = each.value.command
  has_volume     = each.value.has_volume
  volume_name    = "volume-${each.value.container_name}"
  network_name   = "spawn-it-network"
}