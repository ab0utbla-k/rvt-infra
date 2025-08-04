resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-log-group"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_stream" "this" {
  name           = "${var.project_name}-log-stream"
  log_group_name = aws_cloudwatch_log_group.this.name
}