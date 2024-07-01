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

## Encryption

If `var.ecr_encryption_type` is set to KMS and `var.ecr_kms_key_arn` is not specified. A KMS key will be created and used automatically. The generated KMS key settings can be overriden with `var.ecr_kms_key`. KMS is used by default, but `AES256` can be specified with `var.ecr_encryption_type` as an alternative.