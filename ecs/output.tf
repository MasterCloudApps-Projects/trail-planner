output "image_backend_url" {
  value = aws_ecr_repository.backend_repo.repository_url
}

output "image_backend_arn" {
  value = aws_ecr_repository.backend_repo.arn
}