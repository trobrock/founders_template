variable "name" {
  description = "The name to use for resources"
  type        = string
}

variable "app_environment" {
  description = "Environment variables to set on the application container"
  default     = []

  type = list(object({
    name  = string,
    value = string
  }))
}

variable "worker_environment" {
  description = "Environment variables to set on the worker container"
  default     = []

  type = list(object({
    name  = string,
    value = string
  }))
}

variable "app_repository_url" {
  description = "The URL to the image repository for the application container"
  type        = string
}

variable "web_repository_url" {
  description = "The URL to the image repository for the web container"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to launch resources in"
  type        = string
  default     = "us-east-1"
}

variable "app_process_memory" {
  description = "The amount of memory to allocate to the application process"
  type        = number
  default     = 768
}

variable "app_task_cpu" {
  description = "The CPU units to allocate to the application task"
  type        = number
  default     = 256
}

variable "app_task_memory" {
  description = "The memory to allocate to the application task"
  type        = number
  default     = 1024
}

variable "app_task_count" {
  description = "The number of application tasks to run"
  type        = number
  default     = 1
}

variable "worker_task_cpu" {
  description = "The CPU units to allocate to the worker task"
  type        = number
  default     = 256
}

variable "worker_task_memory" {
  description = "The memory to allocate to the worker task"
  type        = number
  default     = 1024
}

variable "worker_task_count" {
  description = "The number of worker tasks to run"
  type        = number
  default     = 1
}

variable "task_subnets" {
  description = "The subnets to launch tasks in"
  type        = list
}

variable "vpc_id" {
  description = "The VPC ID to launch things in"
  type        = string
}

variable "alb_listener" {
  description = "The ALB Listener to use in the load balancer configuration"
}

variable "alb_target_group" {
  description = "The ALB Target Group to use in the load balancer configuration"
}

variable "load_balance_security_group" {
  description = "The Security group for the ALB"
}

variable "key_pair_public_key" {
  description = "The public key for the EC2 Key Pair to use when running remote_console"
  type        = string
}
