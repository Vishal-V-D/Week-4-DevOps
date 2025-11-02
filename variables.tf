# ----------------------------------------------------
# General Settings
# ----------------------------------------------------
variable "aws_region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}
variable "project_name" {
  description = "Project name for tagging and naming"
  type        = string
  default     = "smart-learning"
}


# ----------------------------------------------------
# ECS / Fargate Config
# ----------------------------------------------------
variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS service name"
  type        = string
}

variable "ecr_url" {
  description = "ECR repository URL for pulling images"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for ECS tasks or ALB"
  type        = list(string)
  default     = []
}

variable "user_container_port" {
  description = "Port for User Service container"
  type        = number
  default     = 5000
}

variable "course_container_port" {
  description = "Port for Course Service container"
  type        = number
  default     = 4000
}

# ----------------------------------------------------
# Secrets & Environment Variables
# ----------------------------------------------------
variable "rds_secret_arn" {
  description = "ARN of the RDS secret stored in Secrets Manager"
  type        = string
}

variable "user_secret_vars" {
  description = "Secrets for the User Service container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "course_secret_vars" {
  description = "Secrets for the Course Service container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "user_env_vars" {
  description = "Environment variables for user service"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "course_env_vars" {
  description = "Environment variables for course service"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# ----------------------------------------------------
# Optional Database Secrets (if needed per-service)
# ----------------------------------------------------
variable "user_db_secret_arn" {
  type    = string
  default = null
}

variable "course_db_secret_arn" {
  type    = string
  default = null
}

# ----------------------------------------------------
# Tags
# ----------------------------------------------------
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    scope = "PPI"
  }
}

# ----------------------------------------------------
# ALB / Load Balancer (new additions)
# ----------------------------------------------------
variable "user_tg_arn" {
  description = "Target group ARN for user-service (passed to ECS)"
  type        = string
  default     = null
}

variable "course_tg_arn" {
  description = "Target group ARN for course-service (passed to ECS)"
  type        = string
  default     = null
}

variable "enable_alb" {
  description = "Flag to attach ECS services to ALB"
  type        = bool
  default     = true
}
