resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "monVpc"
  }
}

# subnet
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_a_ip
  availability_zone = "eu-west-1a"

  tags = {
    Name = "publicA"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_b_ip
  availability_zone = "eu-west-1b"
# un commentaire là
  tags = {
    Name = "publicB"
  }
}

resource "aws_subnet" "subnet_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_c_ip
  availability_zone = "eu-west-1a"

  tags = {
    Name = "privateC"
  }
}



resource "aws_route_table" "rtb_a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "rtb_b" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_security_group" "secgr_bastion" {
  vpc_id      = aws_vpc.vpc.id
  name        = "secgr-bastion"
  description = "secgrp bastion"

  tags = {
    Name = "secgr_bastion"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_to_bastion" {
  security_group_id = aws_security_group.secgr_bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_anywhere" {
  security_group_id = aws_security_group.secgr_bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "bastion" {
  ami = var.ami_id
  #   security_groups             = [aws_security_group.secgr_bastion.id]
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.keypair.key_name
  subnet_id                   = aws_subnet.subnet_a.id
  vpc_security_group_ids      = [aws_security_group.secgr_bastion.id]
  iam_instance_profile        = "ec2-admin"

  tags = {
    Name = "bastion"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

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

resource "aws_security_group" "secgr_app" {
  vpc_id      = aws_vpc.vpc.id
  name        = "secgr-app"
  description = "secgrp app"

  tags = {
    Name = "secgr_app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_from_bastion_to_app" {
  security_group_id            = aws_security_group.secgr_app.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.secgr_bastion.id
}

resource "aws_vpc_security_group_egress_rule" "app_to_anywhere" {
  security_group_id = aws_security_group.secgr_app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.secgr_app.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.secgr_alb.id
}

resource "aws_instance" "app" {
  ami = var.ami_id
  #   security_groups             = [ aws_security_group.secgr_app.id ]
  vpc_security_group_ids      = [aws_security_group.secgr_app.id]
  instance_type               = var.instance_type
  associate_public_ip_address = false
  key_name                    = data.aws_key_pair.keypair.key_name
  subnet_id                   = aws_subnet.subnet_c.id
  iam_instance_profile        = "ec2-admin"
  user_data                   = base64encode(file("./userdata.sh"))
  user_data_replace_on_change = true

  tags = {
    Name = "app"
  }
}

resource "aws_eip" "eip" {
  tags = {
    Name = "eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet_a.id

  tags = {
    Name = "app-natgw"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "attach_app_to_tg" {
  target_id        = aws_instance.app.id
  target_group_arn = aws_lb_target_group.app_tg.arn
  port             = 80
}

resource "aws_security_group" "secgr_alb" {
  vpc_id      = aws_vpc.vpc.id
  name        = "secgr-alb"
  description = "secgrp alb"

  tags = {
    Name = "secgr_alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_from_anywhere" {
  security_group_id = aws_security_group.secgr_alb.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_anywhere" {
  security_group_id = aws_security_group.secgr_alb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_alb" "alb" {
  name               = "alb-app"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.secgr_alb.id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
