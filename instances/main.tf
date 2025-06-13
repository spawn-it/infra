# Module used to dispatch docker instances to the module in charge of creating the docker instances

locals {
  processed_instances = {
    for name, inst_config in var.instances : name => merge(
      inst_config,
      name == "backend" ? {
        env_vars = merge(
          inst_config.env_vars,
          {
            "TF_VAR_aws_access_key_id"     = var.host_aws_access_key_id
            "TF_VAR_aws_secret_access_key" = var.host_aws_secret_access_key
            "TF_VAR_aws_default_region"    = var.host_aws_default_region
          }
        )
      } : {}
    )
  }
}

module "docker_instances" {
  # We check his provider to know if we need to use the docker module
  for_each = {
    for name, inst in local.processed_instances : name => inst
    if inst.provider == "docker"
  }
  source         = "../modules/docker/instances"
  image          = each.value.image
  container_name = each.value.container_name
  ports          = each.value.ports
  env_vars       = each.value.env_vars
  command        = each.value.command
  has_volume     = each.value.has_volume
  volume_name    = "volume-${each.value.container_name}"
  network_name   = each.value.network_name
  acces_to_docker = each.value.acces_to_docker
}
