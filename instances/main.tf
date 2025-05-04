module "docker_instances" {
  for_each = {
    for name, inst in var.instances : name => inst
    if inst.provider == "docker"
  }

  source = "../modules/instances/docker"
  config = each.value
}
