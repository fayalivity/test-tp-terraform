variable "ami_id" {
  type    = string
  default = "ami-0ef0975ebdd78b77b"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "env" {
  type        = string
  description = "environment to deploy to"
}

variable "instance_profile" {
  type    = string
  default = "ec2-admin"
}

variable "project" {
  type    = string
  default = "cesi"
}