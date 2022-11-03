output "image_backend_url" {
  value = aws_ecr_repository.backend_repo.repository_url
}

output "image_lambda_url" {
  value = aws_ecr_repository.lambda_repo.repository_url
}

output "image_backend_arn" {
  value = aws_ecr_repository.backend_repo.arn
}

output "image_lambda_arn" {
  value = aws_ecr_repository.lambda_repo.arn
}



