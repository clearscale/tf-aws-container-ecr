data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.private == false ? [1] : []

    content {
      sid = "AllowPublicReadOnlyAccess"

      principals {
        type = "AWS"
        identifiers = coalescelist(
          local.perms_read,
          ["*"],
        )
      }

      actions = [
        "ecr-public:BatchGetImage",
        "ecr-public:GetDownloadUrlForLayer",
      ]
    }
  }

  dynamic "statement" {
    for_each = var.private ? [1] : []

    content{ 
      sid    = "AllowPrivateReadOnlyAccess"
      effect = "Allow"


      principals {
        type = "AWS"
        identifiers = coalescelist(
          local.perms_read_write,
          ["arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:root"],
        )
      }
    
      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::851725560508:root"]
      }

      actions = [
        "ecr:ListTagsForResource",
        "ecr:ListImages",
        "ecr:GetRepositoryPolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:GetLifecyclePolicy",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetAuthorizationToken",
        "ecr:DescribeRepositories",
        "ecr:DescribeImages",
        "ecr:DescribeImageScanFindings",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  }

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
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.private && length(local.perms_write) > 0 ? local.perms_write : []

    content{ 
      sid    = "AllowWriteAccess"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = statement.value
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
    for_each = (length(concat(local.perms_read_write)) > 0 && var.private == false
      ? [local.perms_read_write]
      : []
    )

    content {
      sid = "AllowReadWriteAccess"

      principals {
        type        = "AWS"
        identifiers = statement.value
      }

      actions = [
        "ecr-public:BatchCheckLayerAvailability",
        "ecr-public:CompleteLayerUpload",
        "ecr-public:InitiateLayerUpload",
        "ecr-public:PutImage",
        "ecr-public:UploadLayerPart",
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
    for_each = local.services_enabled

    content {
      sid    = "Allow${title(statement.value.name)}Access"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = [statement.value.service]
      }

      actions = local.ecr_read_actions
    }
  }
}