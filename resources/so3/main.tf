module "spawin-it-so3" {
    source = "../../modules/${var.config.provider}"
    config = var.config
}