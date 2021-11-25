## The deployment is for creating a Lambda-based serverless app
## AWS credentials and an AWS account will be needed for the deployment
## Credentials will need passing into the enviornment that is hosting Terraform
## This will be done via a private *.tfvars file when executing deployment


# Provider block; keys are defined here
provider "aws" {
  region     = "us-east-1"
  secret_key = var.aws_secret_key
  access_key = var.aws_access_key
}