output "db_sg_id" {
  value = aws_security_group.db_sg.id
}

output "db_endpoint" {
  value = aws_db_instance.mysql.endpoint
}