output "alb_dns_name" {
  description = "Public DNS of the ALB"
  value       = aws_lb.this.dns_name
}
output "user_tg_arn" {
  value = aws_lb_target_group.user_tg.arn
}

output "course_tg_arn" {
  value = aws_lb_target_group.course_tg.arn
}
