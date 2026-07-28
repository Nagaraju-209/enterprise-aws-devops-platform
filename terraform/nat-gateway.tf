resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {
    Name        = "nat-eip"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}

resource "aws_nat_gateway" "main" {

  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public.id

  tags = {
    Name        = "enterprise-nat-gateway"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "private-route-table"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route" "private_nat_access" {

  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private" {

  subnet_id = aws_subnet.private.id

  route_table_id = aws_route_table.private.id
}