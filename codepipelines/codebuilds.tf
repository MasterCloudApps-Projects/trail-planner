locals {
  projects  = ["build", "deploy"]
  backend   = ["pre_build", "build"]
}

# Codebuild container project

resource "aws_codebuild_project" "codebuild_backend" {
  count         = length(local.backend)
  name          = "codebuild-backend-${local.backend[count.index]}"
  badge_enabled = false
  service_role  = aws_iam_role.codebuild_container_role.arn

  artifacts {
    type = "CODEPIPELINE"
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
  }

  source {
        type      = "CODEPIPELINE"
        buildspec = file("${path.module}/templates/backend/buildspec_${local.backend[count.index]}.yml")
  }
}



resource "aws_codebuild_project" "codebuild_lambdas" {
  count         = length(local.projects)
  name          = "codebuild-lambdas-${local.projects[count.index]}"
  badge_enabled = false
  service_role  = aws_iam_role.lambda_codebuild_role.arn

  artifacts {
    type           = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:3.0"
    type            = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true

    environment_variable {
      name = "REPO_URI"
      value = var.image_lambda_url
    }
    environment_variable {
      name = "REPO_ARN"
      value = var.image_lambda_arn
    }
    environment_variable {
      name = "RDS_HOST"
      value = var.rds_host
    }
    environment_variable {
      name = "TERRAFORM_VERSION"
      value = var.terraform_ver
    }
    environment_variable {
      name = "ENV_NAMESPACE"
      value = var.env_namespace
    }
    environment_variable {
      name = "AWS_ACCOUNT_ID"
      value = var.account_id
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
      name = "SUBNET_ID"
      value = var.subnet.private[0].id
    }
    environment_variable {
      name = "LAMBDA_SG_ID"
      value = var.lambda_sg.lambda-sg.id
    }
  }

  source {
        type      = "CODEPIPELINE"
        buildspec = file("${path.module}/templates/lambdas/buildspec_${local.projects[count.index]}.yml")
  }
}
