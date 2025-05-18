module "s3_bucket_create" {
  source    = "../modules/common/configs/s3/bucket"
  s3_bucket = var.s3_bucket
  providers = {
    minio = minio.s3
  }
}

module "s3_folder_create" {
  depends_on = [ module.s3_bucket_create ]
  source      = "../modules/common/configs/s3/folder"
  s3_bucket   = var.s3_bucket
  folder_name = "tfstates"
  providers    = {
    minio = minio.s3
  }
}