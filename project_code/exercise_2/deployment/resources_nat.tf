

## An Elastic IP will be needed for the custon NAT gateway
resource "aws_eip" "fortune-vpc-natgw-eip" {
  vpc = true
}

/*
The NAT Gateway will be created 
It will convert private IPs to public for internet access
The NAT Gateway will be on 'fortune-subnet-1"
*/
resource "aws_nat_gateway" "fortune-vpc-natgw" {
  allocation_id = aws_eip.fortune-vpc-natgw-eip.id
  subnet_id     = aws_subnet.fortune-subnet-1.id
  depends_on    = [aws_internet_gateway.fortune-vpc-igw]
}

## A route table will need to be defined to route traffic to NAT gateway
resource "aws_route_table" "fortune-vpc-rt-private" {
  vpc_id = aws_vpc.fortune-vpc.id
  route = {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.fortune-vpc-natgw.id
  }
  tags = {
    Name = "fortune-vpc-rt-private"
  }
}

## The route table has to be associated with the custom VPC
resource "aws_route_table_association" "fortune-vpc-private-1-a" {
  subnet_id      = aws_subnet.fortune-subnet-1.id
  route_table_id = aws_route_table.fortune-vpc-rt-private.id
}