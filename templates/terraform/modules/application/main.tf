data "aws_caller_identity" "current" {}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.name}-ecs-tasks"
  description = "allow inbound access from the ALB only for ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    security_groups = [var.load_balance_security_group.id]
  }

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    self      = true
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = var.name
}

# Execution role for the cluster
data "template_file" "ecs_execution_role" {
  template = file("${path.module}/policies/ecs_execution_role.json")

  vars = {
    aws_account_id = data.aws_caller_identity.current.account_id
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.name}-ecs-execution-role"

  assume_role_policy = data.template_file.ecs_execution_role.rendered
}

resource "aws_iam_role_policy" "ecs_execution_policy" {
  name   = "${var.name}-ecs-execution-policy"
  role   = aws_iam_role.ecs_execution_role.id
  policy = file("${path.module}/policies/ecs_execution.json")
}

# Execution role for the task, this allows the docker image access to AWS resources
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecs-task-execution-role"

  assume_role_policy = data.template_file.ecs_execution_role.rendered
}

data "template_file" "ecs_task_execution_policy" {
  template = file("${path.module}/policies/ecs_task_execution.json")
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name   = "${var.name}-ecs-task-execution-policy"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.template_file.ecs_task_execution_policy.rendered
}
