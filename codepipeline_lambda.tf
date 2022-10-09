# -----------------------------------------------------------------------------
# Resources: CodePipeline
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "artifact_lambda_store" {
  bucket        = "codepipeline-artifacts-lambdas"
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    enabled = true

    expiration {
      days = 5
    }
  }
}

resource "aws_iam_role" "codepipeline_lambda_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    },
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path               = "/"
}

resource "aws_iam_policy" "codepipeline_lambda_policy" {
  description = "Policy to allow codepipeline to execute"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject",
        "s3:GetBucketVersioning"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.artifact_lambda_store.arn}/*"
    },
    {
      "Action" : [
        "codebuild:StartBuild", "codebuild:BatchGetBuilds",
        "cloudformation:*",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action" : [
        "lambda:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline-lambda-attach" {
  role       = aws_iam_role.codepipeline_lambda_role.name
  policy_arn = aws_iam_policy.codepipeline_lambda_policy.arn
}

resource "aws_codepipeline" "pipeline-lambdas" {
  depends_on = [
    aws_codebuild_project.codebuild_lambdas
  ]
  name     = "${var.source_lambdas_repo_name}-${var.source_repo_branch}-Pipeline"
  role_arn = aws_iam_role.codepipeline_lambda_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_lambda_store.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      category         = "Source"
      name             = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["lambda-src"]

      configuration = {
        Owner      = var.source_repo_owner
        Repo       = var.source_lambdas_repo_name
        Branch     = var.source_repo_branch
        OAuthToken = var.source_repo_github_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["lambda-src"]
      output_artifacts = ["lambda-package"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_lambdas.name
      }
    }
  }

  stage {
    name = "DeployLambda"
    action {
      name            = "Deploy"
      category        = "Invoke"
      owner           = "AWS"
      version         = "1"
      provider        = "Lambda"
      run_order       = 1
      input_artifacts = ["lambda-package"]
      configuration   = {
        FunctionName   = "index.handler"
      }
    }
  }

}
