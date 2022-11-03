output "db_port" {
  value = aws_db_instance.db.port
}

output "db_url" {
  value = aws_db_instance.db.address
}
