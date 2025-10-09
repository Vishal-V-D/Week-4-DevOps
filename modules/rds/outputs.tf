output "user_db_endpoint" {
  value = aws_db_instance.user_db.endpoint
}

output "user_db_port" {
  value = aws_db_instance.user_db.port
}

output "user_db_secret_arn" {
  value = aws_secretsmanager_secret.user_db_secret.arn
}

output "course_db_endpoint" {
  value = aws_db_instance.course_db.endpoint
}

output "course_db_port" {
  value = aws_db_instance.course_db.port
}

output "course_db_secret_arn" {
  value = aws_secretsmanager_secret.course_db_secret.arn
}
