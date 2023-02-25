# -----------------------------------------public-sub------------------------------------
resource "aws_subnet" "sub_pub1" {
  vpc_id     = aws_vpc.Main_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_sub1"
    "kubernetes.io/cluster/osos-eks-cluster" = "owned"
    "kubernetes.io/role/internal-elb" = 1
  }
}
resource "aws_subnet" "sub_pub2" {
  vpc_id     = aws_vpc.Main_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_sub2"
    "kubernetes.io/cluster/osos-eks-cluster" = "owned"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# -----------------------------------------private-sub------------------------------------
resource "aws_subnet" "sub_pv1" {
  vpc_id     = aws_vpc.Main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1a"
  tags = {
    Name = "private_sub1"
    "kubernetes.io/cluster/osos-eks-cluster" = "owned"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "sub_pv2" {
  vpc_id     = aws_vpc.Main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-1b"
  tags = {
    Name = "private_sub2"
    "kubernetes.io/cluster/osos-eks-cluster" = "owned"
    "kubernetes.io/role/internal-elb" = 1
  }
}



# -----------------------------------------"internet-gw"------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Main_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

# -----------------------------------------"pub-rout-table"------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.Main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rw"
  }
}

# -----------------------------------------"nat-gw"-------------------------------------------------

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.sub_pub1.id
  tags = {
    Name = "eks-nat-gw"
  }
}

# -----------------------------------------"private-rout-table"------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.Main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "rw-private"
  }
}

# -----------------------------------------"rout-table-association"------------------------------------
resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.sub_pub1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.sub_pub2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pv1" {
  subnet_id      = aws_subnet.sub_pv1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "pv2" {
  subnet_id      = aws_subnet.sub_pv2.id
  route_table_id = aws_route_table.private.id
}
