# WEB
resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/service/${var.name}-web"
  retention_in_days = "14"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/service/${var.name}-app"
  retention_in_days = "14"
}

data "template_file" "web_task_definition" {
  template = file("${path.module}/task_definitions/web.json")

  vars = {
    app_log_path = aws_cloudwatch_log_group.app.name
    web_log_path = aws_cloudwatch_log_group.web.name
    app_image    = "${var.app_repository_url}:latest"
    web_image    = "${var.web_repository_url}:latest"
    environment  = jsonencode(var.app_environment)
    app_memory   = var.app_process_memory
    region       = var.aws_region
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${var.name}-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_task_cpu
  memory                   = var.app_task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = data.template_file.web_task_definition.rendered
}

resource "aws_ecs_service" "web" {
  name            = "${var.name}-web"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = var.app_task_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = var.task_subnets
  }

  load_balancer {
    target_group_arn = var.alb_target_group.id
    container_name   = "web"
    container_port   = "80"
  }

  depends_on = [var.alb_listener]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [task_definition]
  }
}
