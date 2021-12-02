
## A new custom VPC will be created for the "random fortune" web server
resource "aws_vpc" "fortune-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "fortune-vpc"
  }
}

## This creates a public subnet for use by the "random fortune" web server 
resource "aws_subnet" "fortune-subnet-public-1" {
  vpc_id                  = aws_vpc.fortune-vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.0.0/24"

  tags = {
    Name = "fortune-webapp-public-1"
  }
}


## This creates another public subnet for use by the "random fortune" web server 
resource "aws_subnet" "fortune-subnet-public-2" {
  vpc_id                  = aws_vpc.fortune-vpc.id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "fortune-webapp-public-2"
  }
}

## This creates a private subnet for use by the "random fortune" web server 
resource "aws_subnet" "fortune-subnet-private-1" {
  vpc_id                  = aws_vpc.fortune-vpc.id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "fortune-webapp-private-1"
  }
}

## This creates an Internet Gateway for public internet access
resource "aws_internet_gateway" "fortune-vpc-igw" {
  vpc_id = aws_vpc.fortune-vpc.id
  tags = {
    Name = "fortune-vpc-igw"
  }

}


/*
A route table representing public-bound traffic will be defined
The route table will route all traffic to the Internet Gateway
Two assoications will also be defined
They will associate both created subnets to the created route table
*/

## This defines the routing table for the custom VPC
resource "aws_route_table" "fortune-vpc-rt-public" {
  vpc_id = aws_vpc.fortune-vpc.id
  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = ""
      gateway_id                 = "${aws_internet_gateway.fortune-vpc-igw.id}"
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  ]
  tags = {
    Name = "fortune-vpc-rt-public"
  }
}

# Association of "fortune-subnet-1" with the created VPC route table
resource "aws_route_table_association" "fortune-vpc-public-1-a" {
  subnet_id      = aws_subnet.fortune-subnet-public-1.id
  route_table_id = aws_route_table.fortune-vpc-rt-public.id
}

# Association of "fortune-subnet-2" with the created VPC route table
resource "aws_route_table_association" "fortune-vpc-public-2-a" {
  subnet_id      = aws_subnet.fortune-subnet-public-2.id
  route_table_id = aws_route_table.fortune-vpc-rt-public.id
}

