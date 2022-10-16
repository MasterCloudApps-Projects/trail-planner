resource "aws_ecr_repository" "ecr_repo" {
  name                 = "lambda_docker_repo"

  image_scanning_configuration {
    scan_on_push = true
  }
}
