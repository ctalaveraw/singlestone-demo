##
variable "instance_username" {
  description = "This represents the default user for the instance"
  type        = string
  default     = "ec2-user"
}


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

/*
A variable will need to be created to represent paths to the SSH key
for the created EC2 instance
*/
variable "aws_ssh_key_public_fortune" {
  description = "Public SSH key for the created EC2 instance"
  type        = string
}


variable "aws_ssh_key_private_fortune" {
  description = "Private SSH key for the created EC2 instance"
  type        = string
}