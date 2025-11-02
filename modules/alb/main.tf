# ----------------------------------------------------
# Application Load Balancer (Public)
# ----------------------------------------------------
resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb"
  })
}

# ----------------------------------------------------
# Security Group for ALB
# ----------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP access to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
# Target Groups for ECS Services
# ----------------------------------------------------
resource "aws_lb_target_group" "user_tg" {
  name     = "${var.project_name}-user-tg"
  port     = var.user_container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api-docs"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = var.tags
}

resource "aws_lb_target_group" "course_tg" {
  name     = "${var.project_name}-course-tg"
  port     = var.course_container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api-docs"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = var.tags
}

# ----------------------------------------------------
# ALB Listeners
# ----------------------------------------------------
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "ALB is working!"
      status_code  = "200"
    }
  }
}

# User path routing
resource "aws_lb_listener_rule" "user_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user_tg.arn
  }

  condition {
    path_pattern {
      values = ["/user*"]
    }
  }
}

# Course path routing
resource "aws_lb_listener_rule" "course_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.course_tg.arn
  }

  condition {
    path_pattern {
      values = ["/course*"]
    }
  }
}
