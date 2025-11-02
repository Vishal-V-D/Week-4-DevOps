# ------------------------------------------------
# Global
# ------------------------------------------------
aws_region     = "us-east-1"
environment    = "dev"
cluster_name   = "smart-learning-dev"
service_name   = "smart-learning-backend-dev"

# ------------------------------------------------
# Networking
# ------------------------------------------------
vpc_id     = "vpc-0abc1234567890def"
subnet_ids = ["subnet-01abcd2345efgh678", "subnet-09ijkl0123mnop456"]

# ------------------------------------------------
# ECR and ECS
# ------------------------------------------------
ecr_url        = "071784445140.dkr.ecr.us-east-1.amazonaws.com/smart-learning-backend-dev"

# ✅ RDS Secret ARN (verified)
rds_secret_arn = "arn:aws:secretsmanager:us-east-1:071784445140:secret:myapp-db-dev20251102065819710900000003"

# ------------------------------------------------
# Container config
# ------------------------------------------------
user_container_port   = 5000
course_container_port = 4000
desired_count         = 1
assign_public_ip      = true

# ------------------------------------------------
# Env vars for containers (✅ includes DB_NAME)
# ------------------------------------------------
user_env_vars = [
  { name = "DB_HOST", value = "myapp-db-dev.capsi2agwav9.us-east-1.rds.amazonaws.com" },
  { name = "DB_USER", value = "admin" },
  { name = "DB_PORT", value = "3306" },
  { name = "DB_NAME", value = "user_service" },
  { name = "PORT", value = "5000" },
  { name = "ENV", value = "dev" }
]

course_env_vars = [
  { name = "DB_HOST", value = "myapp-db-dev.capsi2agwav9.us-east-1.rds.amazonaws.com" },
  { name = "DB_USER", value = "admin" },
  { name = "DB_PORT", value = "3306" },
  { name = "DB_NAME", value = "course_service" },
  { name = "PORT", value = "4000" },
  { name = "ENV", value = "dev" }
]

# ✅ Secret references (password pulled securely)
user_secret_vars = [
  {
    name      = "DB_PASS"
    valueFrom = "arn:aws:secretsmanager:us-east-1:071784445140:secret:myapp-db-dev20251102065819710900000003:password::"
  }
]

course_secret_vars = [
  {
    name      = "DB_PASS"
    valueFrom = "arn:aws:secretsmanager:us-east-1:071784445140:secret:myapp-db-dev20251102065819710900000003:password::"
  }
]

# ------------------------------------------------
# Tags
# ------------------------------------------------
tags = {
  Project     = "SmartLearning"
  Environment = "dev"
  Owner       = "Vishal"
  Scope       = "PPI"
}
