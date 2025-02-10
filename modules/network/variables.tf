variable "vpc_name" {
  type        = string
  description = "Name of the VPC to create"
}

variable "tag_env" {
  type        = string
  description = "Value of the tag \"env\" to deploy to"
}

variable "tag_projet" {
  type        = string
  description = "Value of the tag \"projet\" to deploy"
}

# Module inside variables
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

variable "app_instance_id" {
  type        = string
  description = "Instance to attach to load balancer"
  default     = ""
}

variable "expose_app" {
  type        = bool
  description = "Boolean: Expore or not application server"
  default     = false
}

variable "app_instance_secgrp_id" {
  type        = string
  default     = ""
  description = "Security group of the instance to attach to load balancer"
}