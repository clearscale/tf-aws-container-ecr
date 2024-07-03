module "kms" {
  source = "github.com/clearscale/tf-aws-kms.git?ref=v1.0.0"
  count  = (var.ecr_kms_key_arn == null && lower(var.ecr_encryption_type) == "kms") ? 1 : 0

  prefix  = var.prefix
  client  = var.client
  project = var.project
  account = var.account
  env     = var.env
  region  = var.region
  name    = var.name

  description                            = lookup(var.ecr_kms_key, "description", "KMS Key for the ${local.name} ECR repository.")
  aliases                                = coalesce(lookup(var.ecr_kms_key, "aliases", null), ["ecr/${local.name}"])
  computed_aliases                       = lookup(var.ecr_kms_key, "computed_aliases", {})
  aliases_use_name_prefix                = lookup(var.ecr_kms_key, "aliases_use_name_prefix", false)
  multi_region                           = lookup(var.ecr_kms_key, "multi_region", false)
  enable_key_rotation                    = lookup(var.ecr_kms_key, "enable_key_rotation", true)
  rotation_period_in_days                = lookup(var.ecr_kms_key, "rotation_period_in_days", 365)
  deletion_window_in_days                = lookup(var.ecr_kms_key, "deletion_window_in_days", 30)
  create_external                        = lookup(var.ecr_kms_key, "create_external", false)
  bypass_policy_lockout_safety_check     = lookup(var.ecr_kms_key, "bypass_policy_lockout_safety_check", false)
  custom_key_store_id                    = lookup(var.ecr_kms_key, "custom_key_store_id", null)
  customer_master_key_spec               = lookup(var.ecr_kms_key, "customer_master_key_spec", "SYMMETRIC_DEFAULT")
  key_material_base64                    = lookup(var.ecr_kms_key, "key_material_base64", null)
  key_usage                              = lookup(var.ecr_kms_key, "key_usage", "ENCRYPT_DECRYPT")
  policy                                 = lookup(var.ecr_kms_key, "policy", null)
  valid_to                               = lookup(var.ecr_kms_key, "valid_to", null)
  key_owners                             = lookup(var.ecr_kms_key, "key_owners", [])
  key_administrators                     = lookup(var.ecr_kms_key, "key_administrators", [])
  key_users                              = lookup(var.ecr_kms_key, "key_users", [])
  key_service_users                      = lookup(var.ecr_kms_key, "key_service_users", [])
  key_service_roles_for_autoscaling      = lookup(var.ecr_kms_key, "key_service_roles_for_autoscaling", [])
  key_symmetric_encryption_users         = lookup(var.ecr_kms_key, "key_symmetric_encryption_users", [])
  key_hmac_users                         = lookup(var.ecr_kms_key, "key_hmac_users", [])
  key_asymmetric_public_encryption_users = lookup(var.ecr_kms_key, "key_asymmetric_public_encryption_users", [])
  key_asymmetric_sign_verify_users       = lookup(var.ecr_kms_key, "key_asymmetric_sign_verify_users", [])
  key_statements                         = lookup(var.ecr_kms_key, "key_statements", {})
  source_policy_documents                = lookup(var.ecr_kms_key, "source_policy_documents", [])
  override_policy_documents              = lookup(var.ecr_kms_key, "override_policy_documents", [])
  enable_route53_dnssec                  = lookup(var.ecr_kms_key, "enable_route53_dnssec", false)
  route53_dnssec_sources                 = lookup(var.ecr_kms_key, "route53_dnssec_sources", [])
  create_replica                         = lookup(var.ecr_kms_key, "create_replica", false)
  primary_key_arn                        = lookup(var.ecr_kms_key, "primary_key_arn", null)
  create_replica_external                = lookup(var.ecr_kms_key, "create_replica_external", false)
  primary_external_key_arn               = lookup(var.ecr_kms_key, "primary_external_key_arn", null)
  grants                                 = lookup(var.ecr_kms_key, "grants", {})
  tags                                   = lookup(var.ecr_kms_key, "tags", null)
}
