
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-bucket-lambdas"
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.env_namespace}_pipeline"
  role_arn = aws_iam_role.lambda_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
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
      output_artifacts = ["source_output"]

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
      name     = "Docker_Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["source_output"]
      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_lambdas[0].name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "Deploy_Docker"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["source_output"]
      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_lambdas[1].name
      }
    }
  }
}
