## Variables defined here

## Name of function defined here
variable "lambda_function_name" {
  description = "Name of the created Lambda function for use elsewhere in code"
  type        = string
  default     = "lambda-random-fortune"
}

## The vairables for granting Terraform access to AWS is defined here
## Actual values are stored in a *.tfvars file
## Create a custom *.tfvars file for personal deployments
variable "aws_access_key" {
  description = "AWS access key; for assuming an identity for resource deployment."
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key; for verifying identity for resource deployment."
  type        = string
}

  