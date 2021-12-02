

## An Elastic IP will be needed for the custom NAT gateway
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
  subnet_id     = aws_subnet.fortune-subnet-public-1.id
}

## A route table will need to be defined to route traffic to NAT gateway
resource "aws_route_table" "fortune-vpc-rt-private" {
  vpc_id = aws_vpc.fortune-vpc.id
  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = "${aws_nat_gateway.fortune-vpc-natgw.id}"
      gateway_id                 = ""
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
    Name = "fortune-vpc-rt-private"
  }
}

## The route table has to be associated with the custom VPC
resource "aws_route_table_association" "fortune-vpc-private-1-a" {
  subnet_id      = aws_subnet.fortune-subnet-private-1.id
  route_table_id = aws_route_table.fortune-vpc-rt-private.id
}