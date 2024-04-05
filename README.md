# Terraform AWS/ECR Registry

This module is designed for the creation and management of ECR Docker image repositories. It automatically applies best practices to configure each repository, while also providing flexibility to override specific values as needed.

## Usage

```terraform
module "ecr" {
  source    = "https://github.com/clearscale/tf-aws-container-ecr.git"


  client   = "example"
  project  = "aws"
  env      = "dev"
  region   = "us-east-1"
  name     = "helloworld"
}
```