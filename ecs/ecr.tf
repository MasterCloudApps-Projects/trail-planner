resource "aws_ecr_repository" "backend_repo" {
  name                 = "backend_docker_repo"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "lambda_repo" {
  name                 = "lambda_docker_repo"

  image_scanning_configuration {
    scan_on_push = true
  }
}
