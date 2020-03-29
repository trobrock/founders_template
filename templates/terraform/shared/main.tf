variable "name" {
  type        = string
  description = "the name of the application"
}

provider "aws" {
  version = "~> 2.31"
}

# PRODUCTION
resource "aws_s3_bucket" "production" {
  bucket = "${var.name}-terraform-production"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "S3 Remote Terraform State Store for production"
  }
}

resource "aws_dynamodb_table" "production" {
  name           = "${var.name}-terraform-production"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table for production"
  }
}
