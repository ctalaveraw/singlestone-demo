
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

## This creates a subnet for use by the "random fortune" web server 
resource "aws_subnet" "fortune-subnet-1" {
  vpc_id                  = aws_vpc.fortune-vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.0.0/16"

  tags = {
    Name = "fortune-webapp-public-1"
  }
}


## This creates another subnet for use by the "random fortune" web server 
resource "aws_subnet" "fortune-subnet-2" {
  vpc_id                  = aws_vpc.fortune-vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  cidr_block              = "10.0.1.0/24"

  tags = {
    Name = "fortune-webapp-public-2"
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
  route = { # Route all IP traffic to Internet Gateway
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fortune-vpc-igw.id
  }
  tags = {
    Name = "fortune-vpc-rt-public"
  }
}

# Association of "fortune-subnet-1" with the created VPC route table
resource "aws_route_table_association" "fortune-vpc-public-1-a" {
  subnet_id      = aws_subnet.fortune-subnet-1.id
  route_table_id = aws_route_table.fortune-vpc-rt-public.id
}

# Association of "fortune-subnet-2" with the created VPC route table
resource "aws_route_table_association" "fortune-vpc-public-2-a" {
  subnet_id      = aws_subnet.fortune-subnet-2.id
  route_table_id = aws_route_table.fortune-vpc-rt-public.id
}