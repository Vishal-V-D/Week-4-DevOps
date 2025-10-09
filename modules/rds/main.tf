
resource "random_password" "user_db_password" {
  length  = 16
  special = true
}

resource "random_password" "course_db_password" {
  length  = 16
  special = true
}


resource "aws_secretsmanager_secret" "user_db_secret" {
  name = "user-service-db-password"
  tags = { scope = "PPI" }
}

resource "aws_secretsmanager_secret_version" "user_db_secret_value" {
  secret_id     = aws_secretsmanager_secret.user_db_secret.id
  secret_string = jsonencode({ password = random_password.user_db_password.result })
}

resource "aws_secretsmanager_secret" "course_db_secret" {
  name = "course-service-db-password"
  tags = { scope = "PPI" }
}

resource "aws_secretsmanager_secret_version" "course_db_secret_value" {
  secret_id     = aws_secretsmanager_secret.course_db_secret.id
  secret_string = jsonencode({ password = random_password.course_db_password.result })
}


resource "aws_security_group" "rds_sg" {
  name        = "smart-learning-rds-sg"
  description = "Allow MySQL access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { scope = "PPI" }
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "smart-learning-rds-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = { scope = "PPI" }
}


resource "aws_db_instance" "user_db" {
  identifier             = "user-service-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  name                   = "user_service"
  username               = var.db_user_username
  password               = random_password.user_db_password.result
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  apply_immediately      = true
  tags                   = { scope = "PPI" }
}


resource "aws_db_instance" "course_db" {
  identifier             = "course-service-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  name                   = "course_service"
  username               = var.db_course_username
  password               = random_password.course_db_password.result
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  apply_immediately      = true
  tags                   = { scope = "PPI" }
}
