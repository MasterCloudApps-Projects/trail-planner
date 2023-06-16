# ---------------------------------------------------------------------------------------------------------------------
# AWS GLOBAL
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = ""
}

variable "family" {
  description = ""
}

variable "terraform_ver" {
  description = ""
}

variable "env_namespace" {
  description = ""
}

variable "account_id" {
  description = ""
}

variable "stack" {
  description = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# CONTAINER
# ---------------------------------------------------------------------------------------------------------------------

variable "image_backend_url" {
  description = ""
}

variable "image_backend_arn" {
  description = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# GITHUB
# ---------------------------------------------------------------------------------------------------------------------

variable "source_repo_owner" {
  description = ""
}

variable "source_repo_branch" {
  description = ""
}

variable "source_repo_github_token" {
  description = ""
}

variable "source_backend_repo_name" {
  description = ""
}

variable "source_frontend_repo_name" {
  description = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS
# ---------------------------------------------------------------------------------------------------------------------

variable "rds_host" {
  description = ""
}

variable "rds_db_username" {
  description = ""
}

variable "rds_db_password" {
  description = ""
}

variable "rds_db_port" {
  description = ""
}

variable "rds_db_name" {
  description = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# NETWORK
# ---------------------------------------------------------------------------------------------------------------------

variable "subnet" {
  description = ""
}

variable "vpc_id" {
  description = ""
}

variable "security_groups" {
  description = ""
}

variable "alb_address" {
  description = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# BUCKET
# ---------------------------------------------------------------------------------------------------------------------

variable "static_web_bucket" {
  description = ""
}

variable "artifacts_bucket" {
  description = ""
}