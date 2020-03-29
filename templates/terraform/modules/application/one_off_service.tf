# ONE OFF
resource "aws_cloudwatch_log_group" "one_off" {
  name              = "/ecs/service/${var.name}-one-off"
  retention_in_days = "14"
}

data "template_file" "one_off_task_definition" {
  template = file("${path.module}/task_definitions/one_off.json")

  vars = {
    app_log_path = aws_cloudwatch_log_group.one_off.name
    app_image    = "${var.app_repository_url}:latest"
    app_memory   = var.app_process_memory
    region       = var.aws_region
    app_memory   = var.app_task_memory
    environment  = jsonencode(var.app_environment)
  }
}

resource "aws_ecs_task_definition" "one_off" {
  family                   = "${var.name}-one_off"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_task_cpu
  memory                   = var.app_task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = data.template_file.one_off_task_definition.rendered
}

resource "aws_ecs_service" "one_off" {
  name            = "${var.name}-one_off"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.one_off.arn
  desired_count   = "0"
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
