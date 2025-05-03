terraform {
  required_version = ">= 1.0.0"
}

module "so3" {
  source = "./resources/so3"
  config = var.so3
}

module "backend" {
  source = "./resources/backend"
  config = var.backend
}