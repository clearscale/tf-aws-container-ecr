module "ecr" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecr.git?ref=9daab0795f9759922a0664c8eca09ade5262cb3e"

  # General
  create                          = true
  repository_name                 = local.name
  repository_type                 = (var.private ? "private" : "public")
  create_repository               = var.create
  repository_force_delete         = var.ecr_force_delete
  public_repository_catalog_data  = (var.private == false) ? var.ecr_public_repository_catalog_data : null
  repository_image_tag_mutability = var.ecr_image_tag_mutability

  # Encryption
  repository_encryption_type = var.ecr_encryption_type
  repository_kms_key         = local.kms_key

  # Repo Lifecycle
  create_lifecycle_policy     = (var.ecr_lifecycle_policy != null)
  repository_lifecycle_policy = (var.ecr_lifecycle_policy != null) ? jsonencode(var.ecr_lifecycle_policy) : null

  # Repo Scanning
  repository_image_scan_on_push = var.ecr_image_scan_on_push

  # Repo Permissions
  create_repository_policy           = false
  attach_repository_policy           = true
  repository_policy                  = coalesce(var.policy, data.aws_iam_policy_document.this[0].json)
  repository_read_access_arns        = local.perms_read
  repository_read_write_access_arns  = local.perms_write
  repository_lambda_read_access_arns = local.perms_read_lambda

  # Registry Permissions
  create_registry_policy = (var.ecr_registry_policy != null)
  registry_policy        = var.ecr_registry_policy

  # Registry pul through cache
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache.html
  registry_pull_through_cache_rules = var.ecr_registry_pull_through_cache_rules

  # Registry Replication
  create_registry_replication_configuration = (
    length(local.perms_copy) > 0 ? true : false
  )
  registry_replication_rules = local.perms_copy

  # Registry Scanning
  manage_registry_scanning_configuration = var.ecr_registry_manage_scanning
  registry_scan_type                     = var.ecr_scan_type
  registry_scan_rules                    = var.ecr_registry_manage_scanning ? var.ecr_scan_rules : []

  # Tags
  tags = var.tags
}
