/*
The deployment is for creating a Lambda-based serverless app
AWS credentials and an AWS account will be needed for the deployment
Credentials will need passing into the enviornment that is hosting Terraform
This will be done via a private *.tfvars file when executing deployment
/*

/*
There will be two triggers for the Lambda function;
Traffic to the API Gateway and HTTP traffic from the ALB.

API Gateway has a limit of 10,000 requeste per second;
ALB specifies no limit on requests per second,
therefore, any web application calling the function
will be linked to the ALB.

*/



# Provider block; keys are defined here
provider "aws" {
  region     = "us-east-1"
  secret_key = var.aws_secret_key
  access_key = var.aws_access_key
}