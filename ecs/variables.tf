variable "image_repo_name" {
    description = "Image repo name"
    type = string
}

variable "fargate-task-service-role" {
  description = "Name of the stack."
  default     = "terraform-role-fargate-trailplanner"
}

variable "stack" {
  description = ""
}

variable "family" {
  description = ""
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "container_port" {
  description = ""
}

variable "aws_region" {
  description = ""
}

variable "cw_log_group" {
  description = "CloudWatch Log Group"
  default     = "TrailPlanner"
}

variable "cw_log_stream" {
  description = "CloudWatch Log Stream"
  default     = "fargate"
}

variable "db_user" {
  description = ""
}

variable "db_password" {
  description = ""
}

variable "db_port" {
  description = ""
}

variable "db_url" {
  description = "resource"
}

variable "db_name" {
  description = ""
}

variable "task_count" {
  description = "Number of ECS tasks to run"
  default     = 1
}

variable "aws_security_group" {
  description = "resource"
}

variable "aws_subnet" {
  description = "resource"
}

variable "aws_alb_target_id" {
  description = "resource"
}



