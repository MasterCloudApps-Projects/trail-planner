# Artifact store s3 bucket

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-general-bucket"
}

# AWS Codepipeline

resource "aws_codepipeline" "codepipeline-backend" {
  depends_on = [
    aws_codebuild_project.codebuild_backend
  ]
  name     = "Backend-Pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "BackendSource"
    action {
      category         = "Source"
      name             = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        Owner      = var.source_repo_owner
        Repo       = var.source_backend_repo_name
        Branch     = var.source_repo_branch
        OAuthToken = var.source_repo_github_token
      }
    }
  }

  stage {
    name = "BuildTestsContainer"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_backend[0].id
      }
    }
  }

  stage {
    name = "BuildContainer"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_backend[1].id
      }
    }
  }

  stage {
    name = "DeployContainer"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      version         = "1"
      provider        = "ECS"
      run_order       = 1
      input_artifacts = ["BuildOutput"]
      configuration = {
        ClusterName       = "${var.stack}-Cluster"
        ServiceName       = "${var.stack}-Service"
        FileName          = "imagedefinitions.json"
        DeploymentTimeout = "15"
      }
    }
  }
}

resource "aws_codepipeline" "static_web_pipeline" {
  name     = "static-web-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.artifacts_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        Owner      = var.source_repo_owner
        Repo       = var.source_frontend_repo_name
        Branch     = var.source_repo_branch
        OAuthToken = var.source_repo_github_token
      }

      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "ThirdParty"
      provider  = "GitHub"
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.static_web_build.id
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "BucketName" = var.static_web_bucket.bucket
        "Extract"    = "true"
      }
      input_artifacts = [
        "BuildArtifact",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "S3"
      run_order        = 1
      version          = "1"
    }
  }
}
