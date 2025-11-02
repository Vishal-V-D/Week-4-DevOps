
# ----------------------------------------------------
# S3 + CloudFront (Frontend Hosting)
# ----------------------------------------------------
module "s3_cloudfront" {
  source      = "./modules/s3_cloudfront"
  bucket_name = "smart-learning-frontend-${var.environment}"

  tags = merge(var.tags, {
    Name = "smart-learning-frontend-${var.environment}"
  })
}

# ----------------------------------------------------
# Default VPC and Subnets
# ----------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ----------------------------------------------------
# RDS (Shared Database)
# ----------------------------------------------------
module "rds" {
  source = "./modules/rds"

  db_name                 = "myapp_db_${var.environment}"
  db_username             = "admin"
  db_engine               = "mysql"
  db_engine_version       = "8.0.43"
  db_instance_class       = "db.t3.micro"
  allocated_storage       = 20
  multi_az                = false
  backup_retention_period = 7
  publicly_accessible     = true
  skip_final_snapshot     = true

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  allowed_cidr_blocks = ["0.0.0.0/0"]

  tags = merge(var.tags, {
    Name        = "myapp-db-${var.environment}"
    Service     = "shared-database"
    Environment = var.environment
  })
}

# ----------------------------------------------------
# ECR (Backend Image Repository)
# ----------------------------------------------------
module "ecr_backend" {
  source      = "./modules/ecr"
  environment = var.environment

  tags = merge(var.tags, {
    Name = "smart-learning-ecr-${var.environment}"
  })
}

# ----------------------------------------------------
# ALB (Load Balancer)
# ----------------------------------------------------
module "alb" {
  source                = "./modules/alb"
  project_name          = var.project_name
  vpc_id                = data.aws_vpc.default.id
  public_subnets        = data.aws_subnets.default.ids
  user_container_port   = var.user_container_port
  course_container_port = var.course_container_port
  tags                  = var.tags
}

# ----------------------------------------------------
# ECS + Fargate (Backend Services)
# ----------------------------------------------------
module "ecs" {
  source             = "./modules/ecs_fargate"

  cluster_name       = var.cluster_name
  service_name       = var.service_name
  ecr_url            = module.ecr_backend.repository_url

  vpc_id             = data.aws_vpc.default.id
  subnet_ids         = data.aws_subnets.default.ids
  assign_public_ip   = true
  desired_count      = 1
  cpu                = 256
  memory             = 512

  # Database & Secrets
  rds_secret_arn     = null
  user_secret_vars   = var.user_secret_vars
  course_secret_vars = var.course_secret_vars
  user_env_vars      = var.user_env_vars
  course_env_vars    = var.course_env_vars

  # ALB Integration
  user_tg_arn        = module.alb.user_tg_arn
  course_tg_arn      = module.alb.course_tg_arn
  enable_alb         = true

  tags = var.tags
}
