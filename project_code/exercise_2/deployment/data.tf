
## Data source to access list of AWS Availiability Zones
data "aws_availability_zones" "available" {}

/*
Data source to access AMI list offered by AWS
"Amazon Linux 2" will be defined
*/
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["self"]
  filter { # No need to use anything but Amazon-made images!
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter { # Filtering for Amazon Linux AMIs using HVM virtualization on EBS
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}
