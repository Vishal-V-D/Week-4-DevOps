output "s3_website_url" {
  value = module.s3_cloudfront.s3_website_url
}

output "cloudfront_domain" {
  value = module.s3_cloudfront.cloudfront_domain
}