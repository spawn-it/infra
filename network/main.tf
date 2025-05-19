module "docker_network" {
  for_each = {
    for name, inst in var.networks : name => inst
    if inst.provider == "docker"
  }
  source       = "../modules/docker/network"
  network_name = each.value.network_name
}