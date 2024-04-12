locals {
  name             = lower(replace(var.name, " ", "-"))
  perms_read       = var.read
  perms_write      = var.write
  perms_copy       = var.copy
  perms_read_write = concat(local.perms_read, local.perms_write)

  services_map = {
    ecr       = { name = "ECR",       service = "ecr.amazonaws.com" }
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
  description = "(Optional). ARNs of resources or services to give read (pull) access to."
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

variable "ecr_manage_scanning" {
  description = "Whether to manage registry scanning configuration."
  type        = bool
  default     = true
}

variable "ecr_scan_type" {
  description = "The type of scan to perform on the registry."
  type        = string
  default     = "ENHANCED"
}

variable "ecr_scan_rules" {
  description = "The rules for the registry scan."
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