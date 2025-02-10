# vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name    = "${var.tag_env}-monVpc"
    env     = var.tag_env
    project = var.tag_projet
  }
}

# subnet
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_a_ip
  availability_zone = "eu-west-1a"

  tags = {
    Name    = "${var.tag_env}-publicA"
    env     = var.tag_env
    project = var.tag_projet
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_b_ip
  availability_zone = "eu-west-1b"

  tags = {
    Name    = "${var.tag_env}-publicB"
    env     = var.tag_env
    project = var.tag_projet
  }
}

resource "aws_subnet" "subnet_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_c_ip
  availability_zone = "eu-west-1a"

  tags = {
    Name    = "${var.tag_env}-privateC"
    env     = var.tag_env
    project = var.tag_projet
  }
}

# Routing
resource "aws_route_table" "rtb_a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.tag_env}-public"
  }
}

resource "aws_route_table" "rtb_b" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.tag_env}-private"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# rtb assoc
resource "aws_route_table_association" "assoc_pub_subnet_a" {
  route_table_id = aws_route_table.rtb_a.id
  subnet_id      = aws_subnet.subnet_a.id
}

resource "aws_route_table_association" "assoc_pub_subnet_b" {
  route_table_id = aws_route_table.rtb_a.id
  subnet_id      = aws_subnet.subnet_b.id
}

resource "aws_route_table_association" "assoc_priv_subnet_c" {
  route_table_id = aws_route_table.rtb_b.id
  subnet_id      = aws_subnet.subnet_c.id
}

# NGW
resource "aws_eip" "eip" {
  tags = {
    Name = "${var.tag_env}-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet_a.id

  tags = {
    Name = "${var.tag_env}-app-natgw"
  }
}