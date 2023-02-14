resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "eks_vpc"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "eks_internet_gateway" {
  vpc_id = aws_vpc.eks_vpc.id

 tags = {
    Name = "eks_igw"
  }

  lifecycle {
    create_before_destroy = true
  }
}

### PUBLIC SUBNETS AND ASSOCIATED ROUTE TABLES

resource "aws_subnet" "eks_public_subnet" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone[0]

  tags = {
    Name                                           = "eks_public"

  }
}

resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.eks_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_internet_gateway.id
}

resource "aws_route_table_association" "eks_public_assoc" {
  subnet_id      = aws_subnet.eks_public_subnet.id
  route_table_id = aws_route_table.eks_public_rt.id
}



resource "aws_eip" "eks_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "eks_ngw" {
  allocation_id = aws_eip.eks_nat_eip.id
  subnet_id     = aws_subnet.eks_public_subnet.id
}


### PRIVATE SUBNETS AND ASSOCIATED ROUTE TABLES

resource "aws_subnet" "eks_private_subnet" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone[1]

  tags = {
    Name                                        = "eks_private"

  }
}

resource "aws_route_table" "eks_private_rt" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "default_private_route" {
  route_table_id         = aws_route_table.eks_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_ngw.id
}

resource "aws_route_table_association" "eks_private_assoc" {
  route_table_id = aws_route_table.eks_private_rt.id
  subnet_id      = aws_subnet.eks_private_subnet.id
}

resource "aws_subnet" "eks_private_subnet2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone[0]

  tags = {
    Name                                        = "eks_private"

  }
}



resource "aws_route_table_association" "eks_private_assoc2" {
  route_table_id = aws_route_table.eks_private_rt.id
  subnet_id      = aws_subnet.eks_private_subnet2.id
}

resource "aws_key_pair" "tf-key-pair" {
key_name = "eks.pem"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "eks.pem"
}
