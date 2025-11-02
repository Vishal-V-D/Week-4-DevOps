variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "ecr_url" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
  default = []
}

variable "vpc_id" {
  type = string
}

variable "cpu" {
  type    = number
  default = 512
}

variable "memory" {
  type    = number
  default = 1024
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "assign_public_ip" {
  type    = bool
  default = true
}

variable "user_container_port" {
  type    = number
  default = 5000
}

variable "course_container_port" {
  type    = number
  default = 4000
}



variable "tags" {
  type    = map(string)
  default = {}
}


variable "user_secret_vars" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
}

variable "course_secret_vars" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
}

variable "rds_secret_arn" {
  description = "ARN of the RDS secret in Secrets Manager"
  type        = string
}

variable "user_env_vars" {
  description = "Environment variables for the user service"
  type        = list(object({
    name  = string
    value = string
  }))
}

variable "course_env_vars" {
  description = "Environment variables for the course service"
  type        = list(object({
    name  = string
    value = string
  }))
}

variable "user_tg_arn" {
  description = "Target group ARN for user service"
  type        = string
  default     = null
}

variable "course_tg_arn" {
  description = "Target group ARN for course service"
  type        = string
  default     = null
}

variable "enable_alb" {
  description = "Whether to attach ECS service to ALB target groups"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS region for CloudWatch logs"
  type        = string
  default     = "us-east-1"
}
