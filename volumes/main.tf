module "docker_volumes" {
  for_each = {
    for name, inst in var.volumes : name => inst
    if inst.provider == "docker"
  }
  source = "./docker"
  config = each.value
}