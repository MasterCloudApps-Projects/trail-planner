locals {
  projects  = ["build", "deploy"]
}

resource "aws_codebuild_project" "codebuild_lambdas" {
  count         = length(local.projects)
  name          = "codebuild-${var.source_lambdas_repo_name}-${var.source_repo_branch}-${local.projects[count.index]}"
  build_timeout = 5
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
      value = aws_ecr_repository.ecr_repo.repository_url
    }
    environment_variable {
      name = "REPO_ARN"
      value = aws_ecr_repository.ecr_repo.arn
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
      value = data.aws_caller_identity.current.account_id
    }
  }

  source {
        type      = "CODEPIPELINE"
        buildspec = file("${path.module}/templates/buildspec_${local.projects[count.index]}.yml")
  }
}