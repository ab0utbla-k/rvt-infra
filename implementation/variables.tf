variable "project_name" {
  type        = string
  default     = "hello-app"
  description = "(Optional) The name of the project"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "(Optional) The name of the environment"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "(Optional) The AWS region"
}

variable "app_port" {
  type        = number
  default     = 4000
  description = "(Optional) The port on which application runs"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "(Optional) The IPv4 CIDR block for the VPC"
}

variable "ecs_task_cpu" {
  type        = number
  description = "(Optional) Number of cpu units used by the task."
  default     = 256
}

variable "ecs_task_memory" {
  type        = number
  description = "(Optional) Amount (in MiB) of memory used by the task."
  default     = 512
}

variable "ecs_desired_count" {
  type        = number
  default     = 2
  description = <<-EOT
    (Optional) Number of instances of the task definition to place and keep running.
    Do not specify if using the DAEMON scheduling strategy.
    Defaults to 2.
  EOT
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "(Optional) The RDS instance class."
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = <<-EOT
    (Optional) The allocated storage in gibibytes.
    If max_allocated_storage is configured, this argument represents the initial storage allocation and differences from the configuration will be ignored automatically when Storage Autoscaling occurs.
    If replicate_source_db is set, the value is ignored during the creation of the instance.
    Default is 20.
  EOT
}

variable "db_max_allocated_storage" {
  type        = number
  default     = 100
  description = <<-EOT
    (Optional) Specifies the maximum storage (in GiB) that Amazon RDS can automatically scale to for this DB instance.
    By default, Storage Autoscaling is enabled. Must be greater than or equal to allocated_storage for autoscaling to work.
    Setting max_allocated_storage to 0 explicitly disables Storage Autoscaling.
    When configured, changes to allocated_storage will be automatically ignored as the storage can dynamically scale.
    Default is 100.
  EOT
}

variable "db_name" {
  type        = string
  default     = "hello"
  description = <<-EOT
    (Optional) The name of the database to create when the DB instance is created.
    If this parameter is not specified, no database is created in the DB instance.
    Default is "hello".
  EOT
}

variable "db_username" {
  type        = string
  default     = "helloadm"
  description = <<-EOT
    (Optional) Username for the master DB user.
    Cannot be specified for a replica.
    Default is "helloadm".
  EOT
}

variable "db_backup_retention_period" {
  type        = number
  default     = 7
  description = <<-EOT
    (Optional) The days to retain backups for.
    Must be between 0 and 35.
    Default is 7.
  EOT
}

variable "db_backup_window" {
  type        = string
  default     = "02:30-03:30"
  description = <<-EOT
    (Optional) The daily time range (in UTC) during which automated backups are created if they are enabled.
    Example: "09:46-10:16".
    Must not overlap with maintenance_window.
    The default is "02:30-03:30".
  EOT
}

variable "db_maintenance_window" {
  type        = string
  default     = "Sun:04:00-Sun:05:00"
  description = <<-EOT
    (Optional) The window to perform maintenance in.
    Syntax: "ddd:hh24:mi-ddd:hh24:mi".
    Eg: "Mon:00:00-Mon:03:00".
    See RDS Maintenance Window docs for more information.
    The default is "Sun:04:00-Sun:05:00".
  EOT
}

variable "db_multi_az" {
  type        = bool
  default     = false
  description = "(Optional) Specifies if the RDS instance is multi-AZ"
}

variable "db_enable_deletion_protection" {
  type        = bool
  default     = false
  description = <<-EOT
    (Optional) If the DB instance should have deletion protection enabled.
    The database can't be deleted when this value is set to true.
    The default is false.
  EOT
}

variable "db_skip_final_snapshot" {
  type        = bool
  default     = false
  description = <<-EOT
    (Optional) Determines whether a final DB snapshot is created before the DB instance is deleted.
    If true is specified, no DBSnapshot is created.
    If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier.
    Default is false.
  EOT
}

variable "db_storage_type" {
  type        = string
  default     = "gp3"
  description = <<-EOT
    (Optional) One of:
      - "standard" (magnetic)
      - "gp2" (general purpose SSD)
      - "gp3" (general purpose SSD that needs iops independently)
      - "io1" (provisioned IOPS SSD)
      - "io2" (block express storage provisioned IOPS SSD).
    Defaults to "gp3".
  EOT
}

variable "alb_enable_deletion_protection" {
  type        = bool
  default     = false
  description = <<-EOT
      (Optional) If true, deletion of the load balancer will be disabled via the AWS API.
      This will prevent Terraform from deleting the load balancer.
      Defaults to false.
  EOT
}

variable "secret_recovery_window_in_days" {
  type        = number
  default     = 30
  description = <<-EOT
    (Optional) Number of days that AWS Secrets Manager waits before it can delete the secret.
    This value can be 0 to force deletion without recovery or range from 7 to 30 days.
    The default value is 30.
  EOT
}

variable "ecr_enable_force_delete" {
  type        = bool
  default     = false
  description = <<-EOT
    (Optional) If true, will delete the repository even if it contains images.
    Defaults to false.
  EOT
}

variable "alert_email" {
  type        = string
  default     = "igorblood906@gmail.com"
  description = <<-EOT
    (Optional) Email address to receive alarm notifications.
    Leave empty to disable email notifications.
  EOT
}