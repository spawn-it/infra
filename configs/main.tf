module "s3_configs" {
  for_each = {
    for name, inst in var.configs : name => inst
    if name == "s3"
  }

  source = "../modules/configs/s3"
  s3_endpoint = each.value.endpoint
  s3_bucket = each.value.bucket
  s3_region = each.value.region
  s3_access_key = each.value.access_key
  s3_secret_key = each.value.secret_key
  providers = {
    aws = aws.s3
  }
}
