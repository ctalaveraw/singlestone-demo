
## This allows usage of the built-in default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

## This allows usage of the default subnet for a given AZ
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"
  tags = {
    Name = "Default subnet for us-east-1a"
  }
}
