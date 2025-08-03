variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "hello-app"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "app_port" {
  type        = number
  description = "Port on which application runs"
  default     = 4000
}

variable "ecs_cpu" {
  type        = number
  description = "CPU units for ECS task"
  default     = 256
}

variable "ecs_memory" {
  type        = number
  description = "Memory for ECS task"
  default     = 512
}

variable "ecs_desired_count" {
  type        = number
  description = "Desired number of ECS tasks"
  default     = 2
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage for RDS"
  default     = 20
}

variable "db_max_allocated_storage" {
  type        = number
  description = "Maximum allocated storage for RDS"
  default     = 100
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "hello"
}

variable "db_username" {
  type        = string
  description = "Database master username"
  default     = "helloadm"
}

variable "db_backup_retention_period" {
  type        = number
  description = "Backup retention period in days"
  default     = 7
}

variable "db_backup_window" {
  type        = string
  description = "Backup window"
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  type        = string
  description = "Maintenance window"
  default     = "Sun:04:00-Sun:05:00"
}

variable "db_multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment"
  default     = false
}

variable "db_deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = true
}

variable "db_final_snapshot" {
  type        = bool
  description = "Take final snapshot on deletion"
  default     = true
}

variable "alb_deletion_protection" {
  type        = bool
  description = "Enable ALB deletion protection"
  default     = false
}

variable "storage_type" {
  type        = string
  description = "Storage type for RDS"
  default     = "gp3"
}