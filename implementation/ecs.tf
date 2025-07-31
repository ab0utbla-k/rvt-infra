resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn           = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = var.project_name
      image = "${aws_ecr_repository.app.repository_url}:latest"
      
      portMappings = [
        {
          containerPort = var.app_port
          protocol      = "tcp"
        }
      ]
      
      /// !!!!!!
      environment = [
        {
          name  = "PORT"
          value = tostring(var.app_port)
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.main.endpoint
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        }
      ]

      secrets = [
        {
          name      = "DB_USER"
          valueFrom = aws_ssm_parameter.db_user.arn
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_ssm_parameter.db_password.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      /// !!!!!!!!!
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.app_port}/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-task"
    Environment = var.environment
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets         = aws_subnet.private_app[*].id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  /// !!!!
  lifecycle {
    ignore_changes = [task_definition]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.project_name
    container_port   = var.app_port
  }

  /// !!!!!!
  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  tags = {
    Name        = "${var.project_name}-service"
    Environment = var.environment
  }

  depends_on = [aws_lb_listener.https]
}