resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for s in aws_subnet.public : s.id]

  enable_deletion_protection = var.alb_deletion_protection
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/healthcheck"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}

# HTTP listener for demo (using AWS-provided ALB DNS)
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 and SSL Certificate setup for production
# Uncomment and configure when using a custom domain managed by Route53
#
# resource "aws_route53_zone" "this" {
#   name = local.domain_name
#   tags = {
#     Environment = var.environment
#   }
# }
#
# resource "aws_acm_certificate" "this" {
#   provider          = aws.us_east_1 # Ensure this provider block exists if you're using CloudFront
#   domain_name       = local.domain_name
#   validation_method = "DNS"
#
#   lifecycle {
#     create_before_destroy = true
#   }
#
#   tags = {
#     Environment = var.environment
#   }
# }
#
# resource "aws_route53_record" "this" {
#   name    = aws_acm_certificate.this.domain_validation_options[0].resource_record_name
#   type    = aws_acm_certificate.this.domain_validation_options[0].resource_record_type
#   zone_id = aws_route53_zone.this.id
#   records = [aws_acm_certificate.this.domain_validation_options[0].resource_record_value]
#   ttl     = 60
# }
#
# resource "aws_acm_certificate_validation" "this" {
#   certificate_arn         = aws_acm_certificate.this.arn
#   validation_record_fqdns = [aws_route53_record.this.fqdn]
# }

# HTTPS listener for production (uncomment when using custom domain)
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2021-06"
#   certificate_arn   = aws_acm_certificate.this.arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.this.arn
#   }
# }
#
# resource "aws_lb_listener" "http_redirect" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = 80
#   protocol          = "HTTP"
#
#   default_action {
#     type = "redirect"
#
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }
