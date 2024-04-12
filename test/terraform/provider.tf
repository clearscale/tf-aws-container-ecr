#
# Specify which provider(s) this module requires.
# https://developer.hashicorp.com/terraform/language/providers/configuration
#
provider "aws" {
  max_retries = 3
  region      = "us-east-1"
}

#
# Current AWS context
#
data "aws_caller_identity" "current" {}