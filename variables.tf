# Global

variable "aws_region" {
  description = "The AWS region to create things in"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile"
}

# VPC

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "172.17.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

# ECR

variable "image_repo_name" {
    description = "Image repo name"
    type = string
}

# ECS

variable "task_count" {
  description = "Number of ECS tasks to run"
  default     = 1
}

variable "container_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8080
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
}

variable "cw_log_group" {
  description = "CloudWatch Log Group"
  default     = "TrailPlanner"
}

variable "cw_log_stream" {
  description = "CloudWatch Log Stream"
  default     = "fargate"
}

variable "fargate-task-service-role" {
  description = "Name of the stack."
  default     = "terraform-role-fargate-trailplanner"
}

# Repo name and branch

variable "source_repo_name" {
    description = "Source repo name"
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

# Codebuild

variable "family" {
  description = "Family of the Task Definition"
  default     = "trailplanner"
}

variable "stack" {
  description = "Name of the stack."
  default     = "TrailPlanner"
}

# RDS

variable "db_profile" {
  description = "RDS Profile"
  default     = "postgres"
}

variable "db_initialize" {
  description = "RDS initialize"
  default     = "yes"
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
  default     = "root"
}

variable "db_password" {
  description = "RDS DB password"
}
