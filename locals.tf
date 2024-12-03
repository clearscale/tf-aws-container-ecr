locals {
  # tflint-ignore: terraform_unused_declarations
  prefix = coalesce(var.prefix, "cs")
  # tflint-ignore: terraform_unused_declarations
  client = coalesce(var.client, "ClearScale")
  # tflint-ignore: terraform_unused_declarations
  project = coalesce(var.project, "pmod")
  # tflint-ignore: terraform_unused_declarations
  account = coalesce(var.account, { id = data.aws_caller_identity.this.account_id, name = "shared" })
  # tflint-ignore: terraform_unused_declarations
  env = coalesce(var.env, "dev")
  # tflint-ignore: terraform_unused_declarations
  region = coalesce(var.region, "us-west-1")
  # tflint-ignore: terraform_unused_declarations
  name = module.std.names.aws[var.account.name].general
  # tflint-ignore: terraform_unused_declarations
  name_std = var.name
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.this.account_id

  # kms key alias
  kms_alias = null

  # Ensure the required tags are included
  mandatory_tags = {}

  # Merge user-provided tags with mandatory tags
  tags = merge(var.tags, local.mandatory_tags)

  partition        = data.aws_partition.this.partition
  perms_write      = var.write
  perms_copy       = var.copy
  perms_read_write = concat(local.perms_read, local.perms_write)

  perms_read = concat(
    [
      for arn in var.read :
      arn if startswith(arn, "arn:")
    ],
    [
      for account_id in var.read :
      "arn:${local.partition}:iam::${account_id}:root" if !startswith(account_id, "arn:")
    ]
  )

  perms_read_lambda = [
    for arn in var.read : arn
    if startswith(arn, "arn:${local.partition}:lambda:")
  ]

  services_map = {
    ecr       = { name = "ECR", service = "ecr.amazonaws.com" }
    ecs       = { name = "ECS", service = "ecs.amazonaws.com" }
    ecs_tasks = { name = "ECSTasks", service = "ecs-tasks.amazonaws.com" }
    eks       = { name = "EKS", service = "eks.amazonaws.com" }
    codebuild = { name = "CodeBuild", service = "codebuild.amazonaws.com" }
    lambda    = { name = "Lambda", service = "lambda.amazonaws.com" }
    beanstalk = { name = "BeanStalk", service = "elasticbeanstalk.amazonaws.com" }
    sagemaker = { name = "SageMaker", service = "sagemaker.amazonaws.com" }
    batch     = { name = "Batch", service = "batch.amazonaws.com" }
  }

  // Filter out the services that are not enabled (i.e., not set to true in the var.services)
  services_enabled = {
    for k, v in var.services : k => local.services_map[k] if v
  }

  // Define the ECR actions separately for reuse
  ecr_read_actions = [
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    "ecr:BatchCheckLayerAvailability",
    "ecr:GetAuthorizationToken"
  ]

  kms_key = ((lower(var.ecr_encryption_type) == "kms")
    ? coalesce(var.ecr_kms_key_arn, module.kms[0].key_arn)
    : null
  )
}

