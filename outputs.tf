output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "alb_dns" {
  value = aws_alb.alb.dns_name
}

output "application_ip" {
  value = aws_instance.app.private_ip
}