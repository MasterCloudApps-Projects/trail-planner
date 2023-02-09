resource "aws_ecr_repository" "backend_repo" {
  name                 = "backend_docker_repo"
  image_tag_mutability = "MUTABLE"
}
