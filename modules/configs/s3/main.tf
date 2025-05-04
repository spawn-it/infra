terraform {
  required_providers {
    aws = {
        ## The AWS provider is used to manage AWS resources.
        ## The provider is configured to use the S3-compatible storage service.
        source  = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}
