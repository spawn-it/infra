terraform {
  required_version = ">= 1.0.0"
}

module "instances" {
  source = "./instances"
  instances = var.instances
}

module "configs" {
  depends_on = [ module.instances ]
  source = "./configs"
  configs = var.configs
}