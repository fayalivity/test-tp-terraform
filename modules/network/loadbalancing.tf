resource "aws_security_group" "secgr_alb" {
  count = var.expose_app ? 1 : 0

  vpc_id      = aws_vpc.vpc.id
  name        = "${var.tag_env}-secgr-alb"
  description = "${var.tag_env}-secgrp alb"

  tags = {
    Name = "${var.tag_env}-secgr_alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_from_anywhere" {
  count = var.expose_app ? 1 : 0

  security_group_id = aws_security_group.secgr_alb[count.index].id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_anywhere" {
  count = var.expose_app ? 1 : 0

  security_group_id = aws_security_group.secgr_alb[count.index].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_alb" "alb" {
  count = var.expose_app ? 1 : 0

  name               = "${var.tag_env}-alb-app"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.secgr_alb[count.index].id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_lb_listener" "http" {
  count = var.expose_app ? 1 : 0

  load_balancer_arn = aws_alb.alb[count.index].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg[count.index].arn
  }
}

resource "aws_lb_target_group" "app_tg" {
  count = var.expose_app ? 1 : 0

  name     = "${var.tag_env}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "attach_app_to_tg" {
  count = var.expose_app ? 1 : 0

  target_id        = var.app_instance_id
  target_group_arn = aws_lb_target_group.app_tg[count.index].arn
  port             = 80
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  count = var.expose_app ? 1 : 0

  security_group_id            = var.app_instance_secgrp_id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.secgr_alb[count.index].id
}