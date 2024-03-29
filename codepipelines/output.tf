output "pipeline_backend_url" {
  value = "https://console.aws.amazon.com/codepipeline/home?region=${var.aws_region}#/view/${aws_codepipeline.codepipeline-backend.id}"
}

output "pipeline_frontend_url" {
  value = "https://console.aws.amazon.com/codepipeline/home?region=${var.aws_region}#/view/${aws_codepipeline.static_web_pipeline.id}"
}