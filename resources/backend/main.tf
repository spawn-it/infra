module "spawin-it-backend" {
    source = "../../modules/${var.config.provider}"
    config = var.config
}