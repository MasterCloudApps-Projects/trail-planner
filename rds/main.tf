
# ---------------------------------------------------------------------------------------------------------------------
# RDS DB SUBNET GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_subnet_group" "db-subnet-grp" {
  name        = "trailplanner-db-sgrp"
  description = "Database Subnet Group"
  subnet_ids  = var.aws_subnet.private.*.id
}

resource "aws_db_parameter_group" "bd-parameter-group" {
  name   = "trailplanner"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS (PostgreSQL)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "db" {
  identifier        = "trailplanner"
  allocated_storage = 5
  engine            = "postgres"
  engine_version    = "14.6"
  port              = "5432"
  instance_class    = var.db_instance_type
  db_name           = var.db_name
  username          = var.db_user
  password          = var.db_password
  availability_zone      = "${var.aws_region}a"
  vpc_security_group_ids = [var.aws_security_group.db-sg.id]
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-grp.id
  parameter_group_name   = aws_db_parameter_group.bd-parameter-group.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}