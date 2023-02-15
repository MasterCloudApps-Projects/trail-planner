output "elastic_beanstalk_app" {
  value = aws_elastic_beanstalk_application.frontend_app
}

output "elastic_beanstalk_app_env" {
  value = aws_elastic_beanstalk_environment.frontend_app_env
}