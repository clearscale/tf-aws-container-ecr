locals {
  name             = lower(replace(var.name, " ", "-"))
  partition        = data.aws_partition.this.partition
  perms_write      = var.write
  perms_copy       = var.copy
  perms_read_write = concat(local.perms_read, local.perms_write)

  perms_read = [
    for arn in var.read : arn
    if !startswith(arn, "arn:${local.partition}:lambda:")
  ]

  perms_read_lambda = [
    for arn in var.read : arn
    if startswith(arn, "arn:${local.partition}:lambda:")
  ]

  services_map = {
    ecr       = { name = "ECR",       service = "ecr.amazonaws.com" }
    ecs       = { name = "ECS"        service = "ecs.amazonaws.com"}
    ecs_tasks = { name = "ECSTasks"   service = "ecs-tasks.amazonaws.com"}
    eks       = { name = "EKS",       service = "eks.amazonaws.com" }
    codebuild = { name = "CodeBuild", service = "codebuild.amazonaws.com" }
    lambda    = { name = "Lambda",    service = "lambda.amazonaws.com" }
    beanstalk = { name = "BeanStalk", service = "elasticbeanstalk.amazonaws.com" }
    sagemaker = { name = "SageMaker", service = "sagemaker.amazonaws.com" }
    batch     = { name = "Batch",     service = "batch.amazonaws.com" }
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

variable "prefix" {
  type        = string
  description = "(Optional). Prefix override for all generated naming conventions."
  default     = "cs"
}

variable "client" {
  type        = string
  description = "(Optional). Name of the client"
  default     = "ClearScale"
}

variable "project" {
  type        = string
  description = "(Optional). Name of the client project."
  default     = "pmod"
}

variable "account" {
  description = "(Optional). Current cloud provider account info."
  type = object({
    key      = optional(string, "current")
    provider = optional(string, "aws")
    id       = optional(string, "*") 
    name     = string
    region   = optional(string, null)
  })
  default = {
    id   = "*"
    name = "shared"
  }
}

variable "env" {
  type        = string
  description = "(Optional). Name of the current environment."
  default     = "dev"
}

variable "region" {
  type        = string
  description = "(Optional). Name of the region."
  default     = "us-west-1"
}

variable "name" {
  type        = string
  description = "(Optional). The name of the resource, application, or service."
}

variable "private" {
  type        = bool
  description = "(Optional). Private or public repository?"
  default     = true
}

variable "create" {
  type        = bool
  description = "(Optional). Whether or not to create the repository. Does it need to be created or do the settings need to be configured?"
  default     = true
}

#
# ARNs of trusted resources or services.
#
variable "read" {
  description = "(Optional). ARNs of resources or services to give read (pull) access to. Any Lambda ARNs will be automatically parsed and moved to `repository_lambda_read_access_arns`."
  type        = list(string)
  default     = []
}

#
# ARNs of trusted resources or services.
# Write access also provides read access.
#
variable "write" {
  description = "(Optional). ARNs of resources or services to give write (push) access to. Write access also provides read access."
  type        = list(string)
  default     = []
}

#
# Allow replication to other regions by specifying region specific repostiroy ARN
# Example:
# copy = [{
#   destinations = [{
#     region      = "us-west-2"
#     registry_id = local.account_id
#     }, {
#     region      = "eu-west-1"
#     registry_id = local.account_id
#   }]

#   repository_filters = [{
#     filter      = "prod-microservice"
#     filter_type = "PREFIX_MATCH"
#   }]
# }]
variable "copy" {
  description = "(Optional). Configuration for registry replication rules including destinations and repository filters."
  type = list(object({
    destinations = optional(list(object({
      region      = optional(string)
      registry_id = optional(string)
    })), [])
    repository_filters = optional(list(object({
      filter      = optional(string)
      filter_type = optional(string)
    })), [])
  }))
  default = []
}

#
# Enable specific AWS services to push or pull images from this repo.
#
variable "services" {
  description = "(Optional). Toggle AWS service access on or off."
  type        = object({
    ecr       = optional(bool, false)
    eks       = optional(bool, false)
    codebuild = optional(bool, false)
    lambda    = optional(bool, false)
    beanstalk = optional(bool, false)
    sagemaker = optional(bool, false)
    batch     = optional(bool, false)
  })
  default = {}
}

variable "ecr_policy_statements" {
  description = "(Optional). A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage."
  type        = any
  default     = {}
}

#
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html
#
variable "ecr_lifecycle_policy" {
  description = "(Optional). Lifecycle policy for the ECR repository."
  type = object({
    rules = list(object({
      rulePriority = number
      description  = string
      selection    = object({
        tagStatus   = string
        countType   = string
        countUnit   = string
        countNumber = number
      })
      action = object({
        type = string
      })
    }))
  })
  default = {
    rules = [{
      rulePriority = 1,
      description  = "Expire untagged images older than 7 days.",
      selection = {
        tagStatus   = "untagged",
        countType   = "sinceImagePushed",
        countUnit   = "days",
        countNumber = 7
      },
      action = {
        type = "expire"
      }
    }]
  }
}

variable "ecr_scan_type" {
  description = "(Optional). The type of scan to perform on the registry."
  type        = string
  default     = "ENHANCED"
}

variable "ecr_scan_rules" {
  description = "(Optional). The rules for the registry scan."
  type = list(object({
    scan_frequency = string
    filter = list(object({
      filter      = string
      filter_type = string
    }))
  }))
  default = [{
    scan_frequency = "SCAN_ON_PUSH"
    filter = [{
      filter      = "*"
      filter_type = "WILDCARD"
    }]
  }]
}

variable "ecr_image_scan_on_push" {
  description = "(Optional). Indicates whether images are scanned after being pushed to the repository (`true`) or not scanned (`false`)."
  type        = bool
  default     = true
}

variable "ecr_encryption_type" {
  description = "(Optional). The encryption type for the repository. Must be one of: `KMS` or `AES256`. Defaults to `KMS`."
  type        = string
  default     = "KMS"

  validation {
    condition     = contains(["KMS", "AES256"], var.ecr_encryption_type)
    error_message = "The encryption type must be one of: 'KMS' or 'AES256'."
  }
}

variable "ecr_kms_key_arn" {
  description = "(Optional). The ARN of the KMS key to use when encryption_type is `KMS`. If not specified, and `var.ecr_encryption_type` = 'KMS', a KMS key will be generated. Otherwise, it uses the default AWS managed key for ECR."
  type        = string
  default     = null
}

variable "ecr_kms_key" {
  description = "(Optional). KMS settings for the ECR repository. It's advised to create your own KMS key and pass the ARN to `var.ecr_kms_key_arn` instead. Like `var.ecr_kms_key_arn` this variable is only used if `var.ecr_encryption_type` = 'KMS'."
  type = object({
    description                            = optional(string, null)
    aliases                                = optional(list(string), [])
    computed_aliases                       = optional(any, {})
    aliases_use_name_prefix                = optional(bool, false)
    multi_region                           = optional(bool, false)
    enable_key_rotation                    = optional(bool, true)
    rotation_period_in_days                = optional(number, 365)
    deletion_window_in_days                = optional(number, 30)
    create_external                        = optional(bool, false)
    bypass_policy_lockout_safety_check     = optional(bool, false)
    custom_key_store_id                    = optional(string, null)
    customer_master_key_spec               = optional(string, "SYMMETRIC_DEFAULT")
    key_material_base64                    = optional(string, null)
    key_usage                              = optional(string, "ENCRYPT_DECRYPT")
    policy                                 = optional(string, null)
    valid_to                               = optional(string, null)
    key_owners                             = optional(list(string), [])
    key_administrators                     = optional(list(string), [])
    key_users                              = optional(list(string), [])
    key_service_users                      = optional(list(string), [])
    key_service_roles_for_autoscaling      = optional(list(string), [])
    key_symmetric_encryption_users         = optional(list(string), [])
    key_hmac_users                         = optional(list(string), [])
    key_asymmetric_public_encryption_users = optional(list(string), [])
    key_asymmetric_sign_verify_users       = optional(list(string), [])
    key_statements                         = optional(any, {})
    source_policy_documents                = optional(list(string), [])
    override_policy_documents              = optional(list(string), [])
    enable_route53_dnssec                  = optional(bool, false)
    route53_dnssec_sources                 = optional(list(any), [])
    create_replica                         = optional(bool, false)
    primary_key_arn                        = optional(string, null)
    create_replica_external                = optional(bool, false)
    primary_external_key_arn               = optional(string, null)
    grants                                 = optional(any, {})
    tags                                   = optional(map(string), null)
  })
  default = {}
}

variable "ecr_public_repository_catalog_data" {
  description = "(Optional). Catalog data configuration for the repository"
  type        = any
  default     = {}
}

variable "ecr_force_delete" {
  description = "(Optional). If `true`, will delete the repository even if it contains images. Defaults to `false`."
  type        = bool
  default     = false
}

variable "ecr_image_tag_mutability" {
  description = "(Optional). The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`. Defaults to `IMMUTABLE`."
  type        = string
  default     = "IMMUTABLE"
}

variable "ecr_registry_policy_create" {
  description = "(Optional). Determines whether a registry policy will be created"
  type        = bool
  default     = false
}

variable "ecr_registry_policy" {
  description = "(Optional). The policy document. This is a JSON formatted string"
  type        = string
  default     = null
}

variable "ecr_registry_manage_scanning" {
  description = "(Optional). Determines whether the registry scanning configuration will be managed."
  type        = bool
  default     = false
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache.html
variable "ecr_registry_pull_through_cache_rules" {
  description = "(Optional). List of pull through cache rules to create"
  type        = map(map(string))
  default     = {}
}

variable "tags" {
  description = "(Optional). A map of tags to assign to the resources"
  type        = map(string)
  default     = null
}