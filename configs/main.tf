# Create an S3 bucket using the common module
module "s3_bucket_create" {
  source = "../modules/common/configs/s3/bucket"
  providers = {
    minio = minio.s3
  }
}

# Create a "tfstates" folder inside the previously created bucket
module "s3_folder_create" {
  source = "../modules/common/configs/s3/folder"
  providers = {
    minio = minio.s3
  }
  depends_on = [module.s3_bucket_create]

  folder_name = "clients"
}

# Create a Keycloak realm using the specified name
module "idp_create_realm" {
  source = "../modules/common/configs/idp/realm"
  # Use the Keycloak provider to interact with the IdP
  providers = {
    keycloak = keycloak.keycloak
  }

  realm_name = var.realm_name
}

# Create users in the newly created Keycloak realm
module "idp_create_users" {
  source = "../modules/common/configs/idp/user"
  providers = {
    keycloak = keycloak.keycloak
  }

  count = length(var.default_users)
  # Implicit dependency on the realm creation
  realm_id = module.idp_create_realm.realm_id
  user     = var.default_users[count.index]
}

module "s3_create_client_folder" {
  source = "../modules/common/configs/s3/folder"
  providers = {
    minio = minio.s3
  }
  depends_on = [module.s3_bucket_create]

  count       = length(var.default_users)
  folder_name = "clients/${module.idp_create_users[count.index].user_id}"
}

# Upload templates to the S3 bucket
module "s3_upload_templates" {
  source = "../modules/common/configs/s3/file"
  providers = {
    minio = minio.s3
  }
  depends_on = [module.s3_bucket_create]

  for_each = toset(var.template_files)

  s3_bucket    = var.s3_bucket
  file         = "templates/${each.value}"
  file_path    = "${path.module}/templates/${each.value}"
  content_type = "application/json"
}

# Create a Keycloak client in the specified realm
module "idp_create_client" {
  source = "../modules/common/configs/idp/client"
  providers = {
    keycloak = keycloak.keycloak
  }
  realm_id = module.idp_create_realm.realm_id
}