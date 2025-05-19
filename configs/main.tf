module "s3_bucket_create" {
  source = "../modules/common/configs/s3/bucket"
  providers = {
    minio = minio.s3
  }
}

module "s3_folder_create" {
  depends_on  = [module.s3_bucket_create]
  source      = "../modules/common/configs/s3/folder"
  folder_name = "tfstates"
  providers = {
    minio = minio.s3
  }
}

module "s3_user_folders_create" {
  depends_on  = [module.s3_bucket_create]
  source      = "../modules/common/configs/s3/folder"
  folder_name = "users"
  providers = {
    minio = minio.s3
  }
  
}

module "idp_create_realm" {
  source     = "../modules/common/configs/idp/realm"
  realm_name = var.realm_name
  providers = {
    keycloak = keycloak.keycloak
  }
}

module "idp_create_users" {
  source        = "../modules/common/configs/idp/user"
  count         = length(var.default_users)
  realm_id      = module.idp_create_realm.realm_id
  user          = var.default_users[count.index]
  providers = {
    keycloak = keycloak.keycloak
  }
}