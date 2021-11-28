

/*
Actual values are stored in a *.tfvars file
Create a custom *.tfvars file for personal deployments
*/

## The variables for granting Terraform access to AWS are defined here
variable "aws_access_key" {
  description = "AWS access key; for assuming an identity for resource deployment."
  type        = string
}
variable "aws_secret_key" {
  description = "AWS secret key; for verifying identity for resource deployment."
  type        = string
}

## The variables representing the Lambda app source code paths are defined here
variable "app_code_path" {
  description = "The path where the Lambda Python app source code is located"
  type        = string
}
variable "app_code_output" {
  description = "The path where the Lambda Python app package is outputted"
  type        = string
}

## Name of Lambda function defined here
variable "lambda_function_name" {
  description = "Name of the created Lambda function for use elsewhere in code"
  type        = string
}