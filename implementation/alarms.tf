resource "aws_sns_topic" "this" {
  name = "${var.project_name}-alerts"
}

resource "aws_cloudwatch_metric_alarm" "ecs_running_task_count" {
  alarm_name          = "${var.project_name}-ecs-running-tasks-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = var.ecs_desired_count
  alarm_description   = "Triggers when the number of running ECS tasks falls below the desired count for 2 minutes"
  alarm_actions       = [aws_sns_topic.this.arn]

  treat_missing_data  = "breaching"

  dimensions = {
    ServiceName = aws_ecs_service.this.name
    ClusterName = aws_ecs_cluster.this.name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage_low" {
  alarm_name          = "${var.project_name}-rds-free-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Minimum"
  threshold           = 10000000000
  alarm_description   = "Triggers when RDS free storage drops below 10 GB for 10 minutes"
  alarm_actions       = [aws_sns_topic.this.arn]

  treat_missing_data  = "breaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.id
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.project_name}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggers when RDS CPU usage is over 80% for 10 minutes"
  alarm_actions       = [aws_sns_topic.this.arn]

  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.id
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name        = "${var.project_name}-ecs-scaling-events"
  description = "Capture ECS auto scaling events"

  event_pattern = jsonencode({
    source        = ["aws.application-autoscaling"]
    "detail-type" = ["Application Auto Scaling Scaling Activity"]
    detail = {
      resourceId = [aws_appautoscaling_target.this.resource_id]
    }
  })
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.ecs_scaling_events.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.this.arn
}

resource "aws_sns_topic_policy" "this" {
  arn = aws_sns_topic.this.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "default"
    Statement = [
      {
        Sid    = "AllowCloudWatchEvents"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.this.arn
      }
    ]
  })
}