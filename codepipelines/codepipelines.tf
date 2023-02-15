# Artifact store s3 bucket

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-general-bucket"
  acl    = "private"
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

resource "aws_codepipeline" "codepipeline-frontend" {
  depends_on = [
    aws_codebuild_project.codebuild_frontend
  ]
  name     = "frontend-Pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "FrontendSource"
    action {
      category         = "Source"
      name             = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceFrontend"]

      configuration = {
        Owner      = var.source_repo_owner
        Repo       = var.source_frontend_repo_name
        Branch     = var.source_repo_branch
        OAuthToken = var.source_repo_github_token
      }
    }
  }

  stage {
    name = "BuildTestsFrontend"
    action {
      name             = "FrontendTestsBuild"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceFrontend"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_frontend[0].id
      }
    }
  }

  stage {
    name = "BuildFrontend"
    action {
      name             = "FrontendBuild"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceFrontend"]
      output_artifacts = ["BuildFrontend"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_frontend[1].id
      }
    }
  }

  stage {
    name = "DeployFrontend"

    action {
      name = "DeployFrontend"
      category = "Deploy"
      owner = "AWS"
      provider = "ElasticBeanstalk"
      input_artifacts = ["BuildFrontend"]
      version = "1"

      configuration = {
        ApplicationName = var.elastic_beanstalk_app.name
        EnvironmentName = var.elastic_beanstalk_app_env.name
      }
    }
  }
}



