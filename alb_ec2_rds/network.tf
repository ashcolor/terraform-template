################################
# VPC
################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

################################
# Internet Gateway
################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}


################################
# NAT Gateway
################################
# NATゲートウェイ作成 Privateサブネット用
# 先にNATゲートウェイ用のEIPを作成する必要がある
resource "aws_eip" "nat-gateway-eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

# NATゲートウェイ作成
resource "aws_nat_gateway" "nat-gateway-1a" {
  allocation_id = aws_eip.nat-gateway-eip.id
  subnet_id     = aws_subnet.public_subnet_1a.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "nat-gateway-1a"
  }
}


################################
# Subnet
################################
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 11) # 10.0.11.0/24
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.prefix}-public-subnet-1a"
  }
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 12) # 10.0.12.0/24
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.prefix}-public-subnet-1c"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 21) # 10.0.21.0/24
  map_public_ip_on_launch = false

  tags = {
    "Name" = "${var.prefix}-private-subnet-1a"
  }
}

resource "aws_subnet" "private_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 22) # 10.0.22.0/24
  map_public_ip_on_launch = false

  tags = {
    "Name" = "${var.prefix}-private-subnet-1c"
  }
}

resource "aws_subnet" "private_subnet_1d" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1d"
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 23) # 10.0.23.0/24
  map_public_ip_on_launch = false

  tags = {
    "Name" = "${var.prefix}-private-subnet-1d"
  }
}

################################
# Public Route Table
################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-public-route"
  }
}

resource "aws_route" "to_internet" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_rt_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_1c" {
  subnet_id      = aws_subnet.public_subnet_1c.id
  route_table_id = aws_route_table.public_rt.id
}

################################
# Private Route Table
################################
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-private-route"
  }
}

resource "aws_route" "private_to_internet" {
  route_table_id         = aws_route_table.private_rt.id
  nat_gateway_id         = aws_nat_gateway.nat-gateway-1a.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_rt_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_rt.id
}
