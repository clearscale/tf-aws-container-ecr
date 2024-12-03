provider "aws" {
  region = local.region
  default_tags {
    tags = local.tags
  }
}

#
# ClearScale Standardization
#
module "std" {
  source = "git::https://github.com/clearscale/tf-standards.git?ref=c1ef5c7b2df858153a3e6ee90d92d70783029704"

  accounts = [local.account]
  prefix   = local.prefix
  client   = local.client
  project  = local.project
  env      = local.env
  region   = local.region
  name     = local.name_std
}

#
# AWS Data Variables
#
data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}