resource "aws_elastic_beanstalk_application" "frontend_app" {
  name        = "elastic_beanstalk_frontend_app"
  description = "elastic_beanstalk_frontend_app"
}

resource "aws_elastic_beanstalk_environment" "frontend_app_env" {
  name                = "elastic_beanstalk_frontend_app_env"
  application         = aws_elastic_beanstalk_application.frontend_app.name
  solution_stack_name = "64bit Amazon Linux 2015.03 v2.0.3 running Go 1.4"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCApplication"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "SubnetsApplication"
    value     = var.subnet.private[*].id
  }
}
