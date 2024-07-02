# Terraform AWS/ECR Registry

This module is designed for the creation and management of ECR Docker image repositories and registries. It automatically applies best practices to configure each repository, while also providing flexibility to override specific values as needed.

## Defaults

| Rule                                      | Notes                                                                                                                                                                                                                                                                                             |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Support encryption.                       | If `var.ecr_encryption_type` is set to KMS and `var.ecr_kms_key_arn` is not specified. A KMS key will be created and used automatically. The generated KMS key settings can be overridden with `var.ecr_kms_key`. KMS is used by default, but AES256 can be specified with `var.ecr_encryption_type` as an alternative. |
| Private repository by default.            | Repositories are marked as private by default and can be changed with `var.private == false`.                                                                                                                                                                                                      |
| Support a default policy.                 | A default IAM security policy is intact. Additional policies can be added using `var.ecr_policy_statements`. If repository READONLY access is the only permission provided. Read, Write, and Copy permissions can be given using `var.read`, `var.write`, and `var.copy` respectively. The default policy can be overridden with `var.policy`.                    |
| Support a default lifecycle policy.       | The default lifecycle is set to expire any untagged images that are older than 7 days.                                                                                                                                                                                                             |
| Perform automatic security scanning.      | Images are set to scan by default every time an image or updated image is pushed to the repository.                                                                                                                                                                                                |
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