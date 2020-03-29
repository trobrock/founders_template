output "application_security_group" {
  value = aws_security_group.ecs_tasks
}

output "web_service_name" {
  value = aws_ecs_service.web.name
}

output "worker_service_name" {
  value = aws_ecs_service.worker.name
}

output "ecs_cluster" {
  value = aws_ecs_cluster.main
}

output "one_off_task_definition_name" {
  value = aws_ecs_task_definition.one_off.family
}
