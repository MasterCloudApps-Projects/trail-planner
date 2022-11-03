variable "db_instance_type" {
  description = "RDS instance type"
  type = string
}

variable "db_name" {
  description = "RDS DB name"
  type = string
}

variable "db_user" {
  description = "RDS DB username"
  type = string
}

variable "db_password" {
  description = "RDS DB password"
  type = string
}

variable "aws_region" {
  description = "Aws subnet to rds"
  type = string
}

variable "aws_subnet" {
  description = "Aws subnet"
  type = any
}

variable "aws_security_group" {
  description = "Aws security group"
  type = any
}