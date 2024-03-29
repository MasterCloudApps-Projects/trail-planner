# ---------------------------------------------------------------------------------------------------------------------
# ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.stack}-Cluster"
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "tasks-service-role" {
  name               = "${var.fargate-task-service-role}ECSTasksServiceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.tasks-service-assume-policy.json
}

data "aws_iam_policy_document" "tasks-service-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "tasks-service-role-attachment" {
  role       = aws_iam_role.tasks-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "task-def-backend" {
  family                   = var.family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.tasks-service-role.arn

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.backend_repo.repository_url}",
    "memory": ${var.fargate_memory},
    "name": "${var.family}",
    "networkMode": "awsvpc",
    "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${var.cw_log_group}",
                "awslogs-region": "${var.aws_region}",
                "awslogs-stream-prefix": "${var.cw_log_stream}"
            }
        },
    "environment": [
            {
                "name": "POSTGRES_USER",
                "value": "${var.db_user}"
            },
            {
                "name": "POSTGRES_PASSWORD",
                "value": "${var.db_password}"
            },
            {
                "name": "POSTGRES_PORT",
                "value": "${var.db_port}"
            },
            {
                "name": "POSTGRES_HOST",
                "value": "${var.db_url}"
            },
            {
                "name": "POSTGRES_DB",
                "value": "${var.db_name}"
            }
    ],
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "service" {
  name            = "${var.stack}-Service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.task-def-backend.arn
  desired_count   = var.task_count
  force_new_deployment = true
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [var.aws_security_group.task-sg.id, var.aws_security_group.db-sg.id]
    subnets         = var.aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = var.aws_alb_target_id
    container_name   = var.family
    container_port   = var.container_port
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "trailplanner-cw-lgrp" {
  name = var.cw_log_group
}