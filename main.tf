data "aws_caller_identity" "current" {}

module "network" {
  source = "./network"
  az_count       = var.az_count
  container_port = var.container_port
  stack          = var.stack
  vpc_cidr       = var.vpc_cidr
}

module "rds" {
  source = "./rds"
  depends_on = [
    module.network,
  ]
  aws_region         = var.aws_region
  aws_security_group = module.network.security_groups
  aws_subnet         = module.network.aws_subnet
  db_instance_type   = var.db_instance_type
  db_name            = var.db_name
  db_password        = var.db_password
  db_user            = var.db_user
}

module ecs {
  source = "./ecs"
  depends_on = [
    module.network,
    module.rds
  ]
  aws_alb_target_id    = module.network.aws_alb_target_id
  db_url               = module.rds.db_url
  aws_region           = var.aws_region
  aws_security_group   = module.network.security_groups
  aws_subnet           = module.network.aws_subnet
  db_name              = var.db_name
  db_password          = var.db_password
  db_port              = var.db_port
  db_user              = var.db_user
  family               = var.family
  image_repo_name      = var.image_repo_name
  stack                = var.stack
  container_port       = var.container_port
}

module codepipelines {
  source = "./codepipelines"
  depends_on = [
    module.ecs
  ]
  image_backend_url = module.ecs.image_backend_url
  image_backend_arn = module.ecs.image_backend_arn
  image_lambda_url = module.ecs.image_lambda_url
  image_lambda_arn  = module.ecs.image_lambda_arn
  aws_region        = var.aws_region
  family            = var.family
  account_id        = data.aws_caller_identity.current.account_id
  env_namespace     = var.env_namespace
  terraform_ver     = var.terraform_ver
  source_backend_repo_name = var.source_backend_repo_name
  source_lambda_repo_name = var.source_lambda_repo_name
  source_repo_branch = var.source_repo_branch
  source_repo_github_token = var.source_repo_github_token
  source_repo_owner = var.source_repo_owner
  stack = var.stack
  rds_host = module.rds.db_url
  rds_db_name = var.db_name
  rds_db_password = var.db_password
  rds_db_username = var.db_user
  rds_db_port = var.db_port
  security_groups = module.network.security_groups
  subnet = module.network.aws_subnet
  vpc_id = module.network.aws_vpc_id
}


