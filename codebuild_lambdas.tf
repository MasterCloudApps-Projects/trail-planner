resource "aws_iam_role" "codebuild_lambdas_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
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
  path = "/"
}

resource "aws_iam_policy" "codebuild_lambdas_policy" {
  description = "Policy to allow codebuild to execute build spec"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents",
        "ecr:GetAuthorizationToken"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.artifact_lambda_store.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild--lambdas-attach" {
  role       = aws_iam_role.codebuild_lambdas_role.name
  policy_arn = aws_iam_policy.codebuild_lambdas_policy.arn
}

resource "aws_codebuild_project" "codebuild_lambdas" {
  name          = "codebuild-${var.source_lambdas_repo_name}-${var.source_repo_branch}"
  build_timeout = 5
  badge_enabled = false
  service_role  = aws_iam_role.codebuild_lambdas_role.arn

  artifacts {
    type           = "CODEPIPELINE"
    namespace_type = "BUILD_ID"
    packaging      = "ZIP"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<BUILDSPEC
version: 0.2

phases:
    install:
        run-as: root
        runtime-versions:
          nodejs: 10
        commands:
            - npm install
    post_build:
        commands:
           - echo " Completed Lambda build... "
artifacts:
  type: zip
  files:
    - '**/*'
BUILDSPEC
  }
}