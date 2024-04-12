# Terraform AWS/ECR Registry

This module is designed for the creation and management of ECR Docker image repositories. It automatically applies best practices to configure each repository, while also providing flexibility to override specific values as needed.

## Usage

```terraform
module "ecr" {
  source = "github.com/clearscale/tf-aws-container-ecr.git?ref=v1.0.0"

  account = {
    id = "*", name = "shared", provider = "aws", key = "current", region = "us-east-1"
  }

  prefix  = local.context.prefix
  client  = local.context.client
  project = local.context.project
  env     = local.account.name
  region  = local.region.name
  name    = local.name

  services = {
    codebuild = true
  }
}
```

## Plan

```bash
terraform plan -var='name=test'
```

## Apply

```bash
terraform apply -var='name=test'
```

## Destroy

```bash
terraform destroy -var='name=test'
```