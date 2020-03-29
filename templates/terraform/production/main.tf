provider "aws" {
  version = "~> 2.8"
}

provider "template" {
  version = "~> 2.0"
}

locals {
  environment       = "production"
  ecr_expire_policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 14 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 14
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

module "vpc" {
  source = "git://github.com/trobrock/terraform-vpc.git?ref=v1.0.0"

  name = "${var.short_name}-${local.environment}"
}

resource "aws_ecr_repository" "app" {
  name = "${var.short_name}-${local.environment}-app"
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy     = local.ecr_expire_policy
}

resource "aws_ecr_repository" "web" {
  name = "${var.short_name}-${local.environment}-web"
}

resource "aws_ecr_lifecycle_policy" "web" {
  repository = aws_ecr_repository.web.name
  policy     = local.ecr_expire_policy
}

module "code_pipeline" {
  source = "git://github.com/trobrock/terraform-code-pipeline.git?ref=v2.0.0"

  short_name  = var.short_name
  environment = local.environment
  repo_owner  = var.github_org
  repo_name   = var.github_repo

  build_environment = [
    {
      name  = "APP_REPOSITORY_URI"
      value = aws_ecr_repository.app.repository_url
    },
    {
      name  = "WEB_REPOSITORY_URI"
      value = aws_ecr_repository.web.repository_url
    },
    {
      name  = "DATABASE_URL"
      value = module.database.url
    },
    {
      name  = "RAILS_ENV"
      value = local.environment
    },
    {
      name  = "REDIS_URL"
      value = module.redis.url
    }
  ]

  lambda_subnet              = module.vpc.private_subnets[0]
  ecs_cluster                = module.application.ecs_cluster
  ecs_security_group_id      = module.application.application_security_group.id
  ecs_task_definition_family = module.application.one_off_task_definition_name
  ecs_task_definition_name   = "one_off"
  deployments = [
    {
      name         = "deploy-web"
      service_name = module.application.web_service_name
      file_name    = "web_imagedefinitions.json"
    },
    {
      name         = "deploy-worker"
      service_name = module.application.worker_service_name
      file_name    = "worker_imagedefinitions.json"
    }
  ]
}

module "database" {
  source = "git://github.com/trobrock/terraform-database.git?ref=v1.0.1"

  name            = "${var.short_name}${local.environment}"
  instance_class  = "db.t2.small"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  security_groups = [module.application.application_security_group.id]
  username        = var.short_name
  password        = "database20200207"
}

module "redis" {
  source = "git://github.com/trobrock/terraform-redis.git?ref=v1.0.0"

  name            = "${var.name}-${local.environment}"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  security_groups = [module.application.application_security_group.id]
}

module "application" {
  source = "git://github.com/trobrock/terraform-rails-application.git?ref=v0.0.2"

  name                = "${var.short_name}-${local.environment}"
  app_repository_url  = aws_ecr_repository.app.repository_url
  web_repository_url  = aws_ecr_repository.web.repository_url
  public_subnets      = module.vpc.public_subnets
  task_subnets        = module.vpc.private_subnets
  vpc_id              = module.vpc.vpc_id
  enable_ssl          = var.enable_ssl
  acm_certificate_arn = aws_acm_certificate.cert[0].arn
  key_pair_public_key = var.ssh_public_key

  app_environment = [
    {
      name  = "DATABASE_URL"
      value = module.database.url
    },
    {
      name  = "REDIS_URL"
      value = module.redis.url
    }
  ]

  worker_environment = [
    {
      name  = "QUEUE"
      value = "*"
    }
  ]
}
