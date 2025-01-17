variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_a_ip" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_b_ip" {
  type    = string
  default = "10.0.2.0/24"
}

variable "subnet_c_ip" {
  type    = string
  default = "10.0.3.0/24"
}

variable "ami_id" {
  type    = string
  default = "ami-0ef0975ebdd78b77b"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}