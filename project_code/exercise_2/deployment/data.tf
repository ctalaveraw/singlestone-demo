
## Data source for AWS availibility zones
data "aws_availability_zones" "available" {}

## Define AMI for use with EC2 instances
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
## Define a template file data for launch configuration
resource "template_file" "user_data" {
  template = "apache_server_bootstrap.sh"
}