# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to create things in"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile"
}

variable "terraform_ver" {
    description = "Terraform Version number for passing it"
    default     = "1.2.2"
    type        = string
}

variable "env_namespace" {
    description = "Namespace env deply lambdas"
    default     = "trailplanner-dev"
    type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "172.17.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

# ---------------------------------------------------------------------------------------------------------------------
# ECR
# ---------------------------------------------------------------------------------------------------------------------

variable "image_repo_name" {
    description = "Image repo name"
    type = string
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS
# ---------------------------------------------------------------------------------------------------------------------

variable "container_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8080
}

# ---------------------------------------------------------------------------------------------------------------------
# GITHUB
# ---------------------------------------------------------------------------------------------------------------------

variable "source_backend_repo_name" {
    description = "Source repo name"
    type = string
}

variable "source_frontend_repo_name" {
    description = "Source lambda repo name"
    type = string
}

variable "source_repo_branch" {
    description = "Source repo branch"
    type = string
}

variable "source_repo_owner" {
    description = "Source repo owner"
    type = string
}

variable "source_repo_github_token" {
    description = "Source repo github token"
    type = string
}

# ---------------------------------------------------------------------------------------------------------------------
# CODEBUILD
# ---------------------------------------------------------------------------------------------------------------------

variable "family" {
  description = "Family of the Task Definition"
  default     = "trailplanner"
}

variable "stack" {
  description = "Name of the stack"
  default     = "TrailPlanner"
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS
# ---------------------------------------------------------------------------------------------------------------------

variable "db_profile" {
  description = "RDS Profile"
  default     = "postgres"
}

variable "db_port" {
  description = "RDS port"
  default     = 5432
}

variable "db_instance_type" {
  description = "RDS instance type"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "RDS DB name"
  default     = "trailplanner"
}

variable "db_user" {
  description = "RDS DB username"
  default     = "postgres"
}

variable "db_password" {
  description = "RDS DB password"
}

# ---------------------------------------------------------------------------------------------------------------------
# S3 FRONTEND
# ---------------------------------------------------------------------------------------------------------------------

variable "static_web_bucket" {
    description = "Bucket website"
    default     = "source-frontend-trail-planner"
    type        = string
}

variable "artifacts_bucket" {
    description = "Artifacts pipeline website"
    default     = "artifacts-frontend-trail-planner"
    type        = string
}
