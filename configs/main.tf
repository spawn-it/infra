module "s3_bucket_create" {
  source = "../modules/common/configs/s3/bucket"
  s3_bucket = var.s3_bucket
  providers = {
    minio = minio.s3
  }
}