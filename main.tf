module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  repository_name   = local.name
  repository_type   = (var.private ? "private" : "public")
  create_repository = var.create

  # Lifecycle
  repository_lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Expire untagged images older than 7 days.",
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed",
        countUnit   = "days"
        countNumber = 7
      },
      action = {
        type = "expire"
      }
    }]
  })

  # Security scanning configuration
  manage_registry_scanning_configuration = true
  registry_scan_type = "ENHANCED"
  registry_scan_rules = [{
    scan_frequency = "SCAN_ON_PUSH"
    filter         = "*"
    filter_type    = "WILDCARD"
  }]
}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.private && length(local.perms_read) > 0 ? [1] : []

    content{ 
      sid    = "AllowPullAccess"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = local.perms_read
      }

      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
      ]
    }
  }

  dynamic "statement" {
    for_each = var.private && length(local.perms_write) > 0 ? [1] : []

    content{ 
      sid    = "AllowPushAccess"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = local.perms_write
      }

      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.private && length(local.perms_copy) > 0 ? [1] : []

    content{ 
      sid       = "AllowReplication"
      effect    = "Allow"
      resources = local.perms_copy
      actions   = [
        "ecr:ReplicateImage"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.private && var.services.codebuild ? [1] : []

    content{ 
      sid    = "AllowCodeBuildAccess"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["codebuild.amazonaws.com"]
      }

      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.private && var.services.lambda ? [1] : []

    content{ 
      sid    = "AllowLambdaAccess"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }

      actions = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
      ]
    }
  }
}

resource "aws_ecr_repository_policy" "this" {
  repository = local.name
  policy     = data.aws_iam_policy_document.this.json
}