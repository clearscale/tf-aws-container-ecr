#
# AWS Data Variables
#
data "aws_caller_identity" "this" {}
data "aws_partition"       "this" {}

#
# ClearScale Standardization
#
module "std" {
  source =  "git::https://github.com/clearscale/tf-standards.git?ref=c1ef5c7b2df858153a3e6ee90d92d70783029704"

  accounts = [var.account]
  prefix   = var.prefix
  client   = var.client
  project  = var.project
  env      = var.env
  region   = var.region
  name     = local.name
}