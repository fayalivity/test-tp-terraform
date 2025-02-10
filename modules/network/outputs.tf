output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_c_subnet_id" {
  value = aws_subnet.subnet_c.id
}

output "public_a_subnet_id" {
  value = aws_subnet.subnet_a.id
}

output "public_b_subnet_id" {
  value = aws_subnet.subnet_b.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}