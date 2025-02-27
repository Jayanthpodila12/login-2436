# VPC
resource "aws_vpc" "lms" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "lms"
  }
}

# Create web Subnets
resource "aws_subnet" "lms-web-sn" {
  vpc_id     = aws_vpc.lms.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "lms-web-subnet"
  }
}

# Create API Subnets
resource "aws_subnet" "lms-api-sn" {
  vpc_id     = aws_vpc.lms.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "lms-api-subnet"
  }
}

# Create db Subnets
resource "aws_subnet" "lms-db-sn" {
  vpc_id     = aws_vpc.lms.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "lms-db-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "lms-gw" {
  vpc_id = aws_vpc.lms.id

  tags = {
    Name = "Lms-Internet-Gateway"
  }
}

# Create public route table
resource "aws_route_table" "lms-pub-rt" {
  vpc_id = aws_vpc.lms.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lms-gw.id
  }
  tags = {
    Name = "lms-public-rt"
  }
}

# Create Web subnet Association
resource "aws_route_table_association" "lms-web-asc" {
  subnet_id      = aws_subnet.lms-web-sn.id
  route_table_id = aws_route_table.lms-pub-rt.id
}

# Create API subnet Association
resource "aws_route_table_association" "lms-api-asc" {
  subnet_id      = aws_subnet.lms-api-sn.id
  route_table_id = aws_route_table.lms-pub-rt.id
}

# Create private route table (db)
resource "aws_route_table" "lms-pvt-rt" {
  vpc_id = aws_vpc.lms.id
  
  tags = {
    Name = "lms-private-rt"
  }
}

# Create db subnet Association
resource "aws_route_table_association" "lms-db-asc" {
  subnet_id      = aws_subnet.lms-db-sn.id
  route_table_id = aws_route_table.lms-pvt-rt.id
}

# Create NACL
resource "aws_network_acl" "lms-NACL" {
  vpc_id = aws_vpc.lms.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "lms-NACL"
  }
}

# NACL Associations - Web
resource "aws_network_acl_association" "lms-nacl-asc-web" {
  network_acl_id = aws_network_acl.lms-NACL.id
  subnet_id      = aws_subnet.lms-web-sn.id
}

# NACL Associations - API
resource "aws_network_acl_association" "lms-nacl-asc-API" {
  network_acl_id = aws_network_acl.lms-NACL.id
  subnet_id      = aws_subnet.lms-api-sn.id
}


# NACL Associations - DB
resource "aws_network_acl_association" "lms-nacl-asc-db" {
  network_acl_id = aws_network_acl.lms-NACL.id
  subnet_id      = aws_subnet.lms-db-sn.id
}

# Web Security Group
resource "aws_security_group" "lms-web-sg" {
  name        = "lms-web-sg"
  description = "Allow Web Traffic"
  vpc_id      = aws_vpc.lms.id

  tags = {
    Name = "lms-web-sg"
  }
}

