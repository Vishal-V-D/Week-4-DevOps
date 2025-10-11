resource "aws_ecr_repository" "this" {
  name                 = "smart-learning-backend-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name        = "smart-learning-backend-${var.environment}"
    scope       = "PPI"
    Project     = "SmartLearningPlatform"
    Environment = var.environment
  })
}
