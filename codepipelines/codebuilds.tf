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

resource "aws_codebuild_project" "static_web_build" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "static-web-build"
  queued_timeout = 480
  service_role   = aws_iam_role.static_build_role.arn

  artifacts {
    encryption_disabled    = false
    name                   = "static-web-build-frontend"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name = "VITE_API_HOST"
      value = var.alb_address
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = file("${path.module}/templates/frontend/buildspec_build.yml")
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}
