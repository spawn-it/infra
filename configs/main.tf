terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

module "s3_configs" {
  for_each = {
    for name, inst in var.configs : name => inst
    if name == "s3"
  }

  source = "../modules/configs/s3"
  s3_bucket = each.value.bucket
}
