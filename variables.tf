locals {
  client       = lower(replace(var.client, " ", "-"))
  project      = lower(replace(var.project, " ", "-"))
  account_id   = lower(trimspace(replace(var.account.id,   "-", "")))
  account_name = lower(trimspace(replace(var.account.name, "-", "")))
  envname      = lower(trimspace(var.env))
  region       = lower(replace(replace(var.region, " ", "-"), "-", ""))
  name         = lower(replace(var.name, " ", "-"))

  prefix = (try(
    trimspace(var.prefix),
    "${local.client}-${local.project}")
  )

  env = (local.envname == "default" && terraform.workspace == "default"
    ? "dev"
    : local.envname
  )

  perms_read  = var.read
  perms_write = var.write
  perms_copy  = []

  policy_enabled = (
    length(local.perms_read)  > 0 ||
    length(local.perms_write) > 0 ||
    length(local.perms_copy)  > 0
  )

  rex_arn = "arn:aws:([^:]+)?:([^:]+)?:([0-9]+)?:"
  ext_accounts = distinct([     # Grab all external account IDs from ARNs
    for arn in flatten([local.perms_read, local.perms_write]) : (
      regex(local.rex_arn, arn)[2]
    ) if try(regex(local.rex_arn, arn)[2], var.account.id) != var.account.id
  ])
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
  description = "(Optional). Cloud provider account object."
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
  description = "(Optional). AWS region."
  default     = "us-west-1"
}

variable "name" {
  type        = string
  description = "(Required). Name of the ECR repository."
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
# ARNs of trusted roles or AWS accounts.
# Adding ARNs here will give read access to those resources.
#
variable "read" {
  description = "(Optional). ARNs, Accounts, or IAM roles to give read (pull) access to."
  type        = list(string)
  default     = []
}

#
# ARNs of trusted roles or AWS accounts.
# Adding ARNs here will give write access to those resources.
#
variable "write" {
  description = "(Optional). ARNs, Accounts, or IAM roles to give write (push) access to."
  type        = list(string)
  default     = []
}

#
# Allow replication to other regions by specifying region specific repostiroy ARN
#
# Example:
# ["arn:aws:ecr:us-east-1:012345678901:repository/"]
#
variable "copy" {
  description = "(Optional). Allow cross-region replication to these repostory ARNs. (NOTE: Note tested)."
  type        = list(string)
  default     = []
}

#
# Enable specific AWS services to push or pull images from this repo.
#
variable "services" {
  description = "(Optional). Toggle AWS service access on or off."
  type        = object({
    codebuild = optional(bool, true)
    lambda    = optional(bool, false)
  })
  default = {}
}