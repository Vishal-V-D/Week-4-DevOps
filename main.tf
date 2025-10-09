module "s3_cloudfront" {
  source = "./modules/s3_cloudfront"

  bucket_name = "smart-learning-platform-frontend"

  tags = {
    Name  = "Smart-Learning-Platform"
    scope = "PPI"
  }
}

module "rds" {
  source = "./modules/rds"

  db_user_username   = var.db_user_username
  db_course_username = var.db_course_username

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  allowed_cidr_blocks = var.allowed_cidr_blocks

  tags = {
    Name  = "Smart-Learning-Platform-RDS"
    scope = "PPI"
  }
}