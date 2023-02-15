locals {
  steps   = ["pre_build", "build"]
}

# Codebuild backend container project

resource "aws_codebuild_project" "codebuild_backend" {
  count         = length(local.steps)
  name          = "codebuild-backend-${local.steps[count.index]}"
  badge_enabled = false
  service_role  = aws_iam_role.codebuild_container_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }
  vpc_config {
    vpc_id = var.vpc_id
    subnets = var.subnet.private[*].id
    security_group_ids = [var.security_groups.task-sg.id]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name = "REPOSITORY_URI"
      value = var.image_backend_url
    }
    environment_variable {
      name = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
    environment_variable {
      name = "CONTAINER_NAME"
      value = var.family
    }
    environment_variable {
      name = "AWS_ACCOUNT_ID"
      value = var.account_id
    }
    environment_variable {
      name = "RDS_HOST"
      value = var.rds_host
    }
    environment_variable {
      name = "RDS_DB_USERNAME"
      value = var.rds_db_username
    }
    environment_variable {
      name = "RDS_DB_NAME"
      value = var.rds_db_name
    }
    environment_variable {
      name = "RDS_DB_PASSWORD"
      value = var.rds_db_password
    }
    environment_variable {
      name = "RDS_DB_PORT"
      value = var.rds_db_port
    }
  }

  source {
        type      = "CODEPIPELINE"
        buildspec = file("${path.module}/templates/backend/buildspec_${local.steps[count.index]}.yml")
  }
}

# Codebuild frontend container project

resource "aws_codebuild_project" "codebuild_frontend" {
  count         = length(local.steps)
  name          = "codebuild-frontend-${local.steps[count.index]}"
  badge_enabled = false
  service_role  = aws_iam_role.codebuild_container_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }
  vpc_config {
    vpc_id = var.vpc_id
    subnets = var.subnet.private[*].id
    security_group_ids = [var.security_groups.task-sg.id]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
        type      = "CODEPIPELINE"
        buildspec = file("${path.module}/templates/frontend/buildspec_${local.steps[count.index]}.yml")
  }
}
