module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.2.0"

  # General
  repository_name   = local.name
  repository_type   = (var.private ? "private" : "public")
  create_repository = var.create

  # Lifecycle
  repository_lifecycle_policy = jsonencode(var.ecr_lifecycle_policy)

  # Scanning
  manage_registry_scanning_configuration = var.ecr_manage_scanning
  registry_scan_type                     = var.ecr_scan_type
  registry_scan_rules                    = var.ecr_manage_scanning ? var.ecr_scan_rules : []

  # Repositry permissions
  create_repository_policy          = false
  repository_policy                 = data.aws_iam_policy_document.this.json
  repository_read_access_arns       = local.perms_read
  repository_read_write_access_arns = local.perms_write

  # Replication
  create_registry_replication_configuration  = (
    length(local.perms_copy) > 0 ? true : false 
  )
  registry_replication_rules = local.perms_copy
}
