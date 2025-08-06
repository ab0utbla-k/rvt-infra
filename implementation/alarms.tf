resource "aws_sns_topic" "this" {
  name = "${var.project_name}-alerts"
}

resource "aws_cloudwatch_metric_alarm" "ecs_running_task_count" {
  alarm_name          = "${var.project_name}-ecs-running-tasks-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_desired_count
  alarm_description   = "This metric monitors ECS running task count"
  alarm_actions       = [aws_sns_topic.this.arn]

  dimensions = {
    ServiceName = aws_ecs_service.this.name
    ClusterName = aws_ecs_cluster.this.name
  }
}