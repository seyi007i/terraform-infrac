output "db_sg_id" {
  value = aws_security_group.db_sg1.id
}

output "db_endpoint" {
  value = aws_db_instance.mysql.endpoint
}