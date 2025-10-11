output "s3_website_url" {
  value = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.frontend_cdn.domain_name
}

