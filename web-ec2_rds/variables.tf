# Common
variable "prefix" {
  description = "Project name given as a prefix"
  type        = string
}

# VPC
variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
