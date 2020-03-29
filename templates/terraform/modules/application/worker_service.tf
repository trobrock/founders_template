# WORKER
resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/service/${var.name}-worker"
  retention_in_days = "14"
}

data "template_file" "worker_task_definition" {
  template = file("${path.module}/task_definitions/worker.json")

  vars = {
    app_log_path      = aws_cloudwatch_log_group.worker.name
    app_image         = "${var.app_repository_url}:latest"
    app_memory        = var.app_process_memory
    region            = var.aws_region
    worker_app_memory = var.worker_task_memory
    environment       = jsonencode(var.worker_environment)
  }
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.name}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.worker_task_cpu
  memory                   = var.worker_task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = data.template_file.worker_task_definition.rendered
}

resource "aws_ecs_service" "worker" {
  name            = "${var.name}-worker"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_task_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = var.task_subnets
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [task_definition]
  }
}
