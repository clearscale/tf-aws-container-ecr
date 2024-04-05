locals {
  name         = lower(replace(var.name, " ", "-"))

  perms_read  = var.read
  perms_write = var.write
  perms_copy  = []
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

variable "env" {
  type        = string
  description = "(Optional). Name of the current environment."
  default     = "dev"
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
# variable "copy" {
#   description = "(Optional). Allow cross-region replication to these repostory ARNs. (NOTE: Note tested)."
#   type        = list(string)
#   default     = []
# }

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