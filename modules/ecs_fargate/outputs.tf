output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "service_name" {
  value = aws_ecs_service.this.name
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}


# ----------------------------------------------------
# Optional Outputs
# ----------------------------------------------------
output "ecs_log_group_name" {
  value = aws_cloudwatch_log_group.ecs_logs.name
}

output "ecs_log_group_url" {
  value = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.ecs_logs.name, "/", "$252F")}"
}
