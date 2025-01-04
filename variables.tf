#
# Override var
# tflint-ignore: terraform_unused_declarations
variable "overrides" {
  description = "A map of overrides to pass to the module that can be used by the local overrides"
  type        = map(any)
  default     = {}
}

#
# Std Parameters
#

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
  default     = "us-east-1"
}

variable "name" {
  type        = string
  description = "(Required). The name of the resource, application, or service."
}

#
# ECR Parameters
#

variable "private" {
  type        = bool
  description = "(Optional). Private or public repository?. When creating a public repository (private = false), the region must be set to 'us-east-1'."
  default     = true
}

variable "create" {
  type        = bool
  description = "(Optional). Whether or not to create the repository. Does it need to be created or do the settings need to be configured?"
  default     = true
}

variable "policy" {
  type        = string
  description = "(Optional). A aws_iam_policy_document json encoded string to override the default repository policy."
  default     = null
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
# Allow replication to other regions by specifying region specific repository ARN
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
  type = object({
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
      selection = object({
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
  type        = any
  default     = {}
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

variable "ssm_parameter_name" {
  type        = string
  description = "(Required). SSM parameter name to store resource ARN."
  default     = null
}

variable "tags" {
  description = "(Optional). A map of tags to assign to the resources"
  type        = map(string)
  default     = null
}
