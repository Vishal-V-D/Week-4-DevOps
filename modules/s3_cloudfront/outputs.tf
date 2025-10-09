output "s3_website_url" {
  value = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.frontend_cdn.domain_name
}

output "user_db_endpoint" {
  value = module.rds.user_db_endpoint
}

output "user_db_port" {
  value = module.rds.user_db_port
}

output "user_db_secret_arn" {
  value = module.rds.user_db_secret_arn
}

output "course_db_endpoint" {
  value = module.rds.course_db_endpoint
}

output "course_db_port" {
  value = module.rds.course_db_port
}

output "course_db_secret_arn" {
  value = module.rds.course_db_secret_arn
}