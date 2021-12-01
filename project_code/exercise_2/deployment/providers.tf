# project requires the use of the AWS cloud platform, so the appropriate provider is needed

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.66"
    }
  }
}
