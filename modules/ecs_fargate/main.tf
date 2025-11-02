# ----------------------------------------------------
# ECS Cluster
# ----------------------------------------------------
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

# ----------------------------------------------------
# IAM Role for ECS Task Execution
# ----------------------------------------------------
resource "aws_iam_role" "task_execution_role" {
  name = "${var.cluster_name}-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach ECS Task Execution Policy (for ECR + CloudWatch logs)
resource "aws_iam_role_policy_attachment" "task_execution_attach" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ----------------------------------------------------
# 🔐 Allow ECS to read from Secrets Manager
# ----------------------------------------------------
resource "aws_iam_role_policy" "ecs_secret_access" {
  name = "${var.cluster_name}-ecs-secret-access"
  role = aws_iam_role.task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = var.rds_secret_arn != null ? var.rds_secret_arn : "*"
      }
    ]
  })
}

# ----------------------------------------------------
# Security Group for ECS
# ----------------------------------------------------
resource "aws_security_group" "ecs_sg" {
  name        = "${var.cluster_name}-ecs-sg"
  description = "ECS Fargate SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic (adjust for production)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# ----------------------------------------------------
# CloudWatch Log Group (for both containers)
# ----------------------------------------------------
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 7
  tags              = var.tags
}

# ----------------------------------------------------
# ECS Task Definition (✅ with Logging + Health Checks)
# ----------------------------------------------------
resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "user-service"
      image = "${var.ecr_url}:user-latest"
      essential = true
      portMappings = [{
        containerPort = var.user_container_port
        protocol      = "tcp"
      }]
      secrets     = var.user_secret_vars
      environment = var.user_env_vars

      # ✅ CloudWatch logging
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "user"
        }
      }

      # ✅ Container-level health check
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.user_container_port}/api-docs || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    },
    {
      name  = "course-service"
      image = "${var.ecr_url}:course-latest"
      essential = true
      portMappings = [{
        containerPort = var.course_container_port
        protocol      = "tcp"
      }]
      secrets     = var.course_secret_vars
      environment = var.course_env_vars

      # ✅ CloudWatch logging
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "course"
        }
      }

      # ✅ Container-level health check
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.course_container_port}/api-docs || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    }
  ])
}

# ----------------------------------------------------
# ECS Service (✅ ALB config preserved)
# ----------------------------------------------------
resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = var.assign_public_ip
  }

  # Attach both target groups to the ALB
  dynamic "load_balancer" {
    for_each = var.enable_alb ? [1] : []
    content {
      target_group_arn = var.user_tg_arn
      container_name   = "user-service"
      container_port   = var.user_container_port
    }
  }

  dynamic "load_balancer" {
    for_each = var.enable_alb ? [1] : []
    content {
      target_group_arn = var.course_tg_arn
      container_name   = "course-service"
      container_port   = var.course_container_port
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.ecs_logs
  ]

  tags = var.tags
}
