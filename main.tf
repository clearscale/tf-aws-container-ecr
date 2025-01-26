# provider "aws" {
#   region = local.region
#   default_tags {
#     tags = local.tags
#   }
# }

#
# ClearScale Standardization
#
module "std" {
  source =  "github.com/clearscale/tf-standards.git"

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
data "aws_partition"       "this" {}
