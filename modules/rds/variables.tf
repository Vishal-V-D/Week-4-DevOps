variable "db_user_username" {
  description = "Master DB username for user_service DB"
  type        = string
  default     = "admin_user"
}

variable "db_course_username" {
  description = "Master DB username for course_service DB"
  type        = string
  default     = "admin_course"
}

variable "vpc_id" {
  description = "VPC ID for the RDS"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access RDS"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
