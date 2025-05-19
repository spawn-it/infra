# Create an S3 bucket using the common module
module "s3_bucket_create" {
  source = "../modules/common/configs/s3/bucket"
  providers = {
    minio = minio.s3
  }
}

# Create a "tfstates" folder inside the previously created bucket
module "s3_folder_create" {
  source      = "../modules/common/configs/s3/folder"
  providers = {
    minio = minio.s3
  }
  depends_on  = [module.s3_bucket_create]

  folder_name = "tfstates"
}

# Create a "users" folder inside the same bucket
module "s3_user_folders_create" {
  source      = "../modules/common/configs/s3/folder"
  providers = {
    minio = minio.s3
  }
  depends_on  = [module.s3_bucket_create]
  
  folder_name = "users"
}

# Create a Keycloak realm using the specified name
module "idp_create_realm" {
  source     = "../modules/common/configs/idp/realm"
  # Use the Keycloak provider to interact with the IdP
  providers = {
    keycloak = keycloak.keycloak
  }

  realm_name = var.realm_name
}

# Create users in the newly created Keycloak realm
module "idp_create_users" {
  source        = "../modules/common/configs/idp/user"
  providers = {
    keycloak = keycloak.keycloak
  }

  count         = length(var.default_users)
  # Implicit dependency on the realm creation
  realm_id      = module.idp_create_realm.realm_id
  user          = var.default_users[count.index]
}
