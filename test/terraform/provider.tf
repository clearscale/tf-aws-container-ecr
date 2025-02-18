#
# Specify which provider(s) this module requires.
# https://developer.hashicorp.com/terraform/language/providers/configuration
#
terraform {
  required_version = ">= 1.5.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  max_retries = 3
  region      = "us-east-1"
}
