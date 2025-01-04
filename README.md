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
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr"></a> [ecr](#module\_ecr) | git::https://github.com/terraform-aws-modules/terraform-aws-ecr.git | 9daab0795f9759922a0664c8eca09ade5262cb3e |
| <a name="module_kms"></a> [kms](#module\_kms) | github.com/clearscale/tf-aws-kms.git | n/a |
| <a name="module_ssm"></a> [ssm](#module\_ssm) | git::https://github.com/terraform-aws-modules/terraform-aws-ssm-parameter.git | b7659e8b46aa626065c60fbfa7b78c1fedf43d7c |
| <a name="module_std"></a> [std](#module\_std) | github.com/clearscale/tf-standards.git | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account"></a> [account](#input\_account) | (Optional). Current cloud provider account info. | <pre>object({<br>    key      = optional(string, "current")<br>    provider = optional(string, "aws")<br>    id       = optional(string, "*")<br>    name     = string<br>    region   = optional(string, null)<br>  })</pre> | <pre>{<br>  "id": "*",<br>  "name": "shared"<br>}</pre> | no |
| <a name="input_client"></a> [client](#input\_client) | (Optional). Name of the client | `string` | `"ClearScale"` | no |
| <a name="input_copy"></a> [copy](#input\_copy) | (Optional). Configuration for registry replication rules including destinations and repository filters. | <pre>list(object({<br>    destinations = optional(list(object({<br>      region      = optional(string)<br>      registry_id = optional(string)<br>    })), [])<br>    repository_filters = optional(list(object({<br>      filter      = optional(string)<br>      filter_type = optional(string)<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | (Optional). Whether or not to create the repository. Does it need to be created or do the settings need to be configured? | `bool` | `true` | no |
| <a name="input_ecr_encryption_type"></a> [ecr\_encryption\_type](#input\_ecr\_encryption\_type) | (Optional). The encryption type for the repository. Must be one of: `KMS` or `AES256`. Defaults to `KMS`. | `string` | `"KMS"` | no |
| <a name="input_ecr_force_delete"></a> [ecr\_force\_delete](#input\_ecr\_force\_delete) | (Optional). If `true`, will delete the repository even if it contains images. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_ecr_image_scan_on_push"></a> [ecr\_image\_scan\_on\_push](#input\_ecr\_image\_scan\_on\_push) | (Optional). Indicates whether images are scanned after being pushed to the repository (`true`) or not scanned (`false`). | `bool` | `true` | no |
| <a name="input_ecr_image_tag_mutability"></a> [ecr\_image\_tag\_mutability](#input\_ecr\_image\_tag\_mutability) | (Optional). The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`. Defaults to `IMMUTABLE`. | `string` | `"IMMUTABLE"` | no |
| <a name="input_ecr_kms_key"></a> [ecr\_kms\_key](#input\_ecr\_kms\_key) | (Optional). KMS settings for the ECR repository. It's advised to create your own KMS key and pass the ARN to `var.ecr_kms_key_arn` instead. Like `var.ecr_kms_key_arn` this variable is only used if `var.ecr_encryption_type` = 'KMS'. | `any` | `{}` | no |
| <a name="input_ecr_kms_key_arn"></a> [ecr\_kms\_key\_arn](#input\_ecr\_kms\_key\_arn) | (Optional). The ARN of the KMS key to use when encryption\_type is `KMS`. If not specified, and `var.ecr_encryption_type` = 'KMS', a KMS key will be generated. Otherwise, it uses the default AWS managed key for ECR. | `string` | `null` | no |
| <a name="input_ecr_lifecycle_policy"></a> [ecr\_lifecycle\_policy](#input\_ecr\_lifecycle\_policy) | (Optional). Lifecycle policy for the ECR repository. | <pre>object({<br>    rules = list(object({<br>      rulePriority = number<br>      description  = string<br>      selection = object({<br>        tagStatus   = string<br>        countType   = string<br>        countUnit   = string<br>        countNumber = number<br>      })<br>      action = object({<br>        type = string<br>      })<br>    }))<br>  })</pre> | <pre>{<br>  "rules": [<br>    {<br>      "action": {<br>        "type": "expire"<br>      },<br>      "description": "Expire untagged images older than 7 days.",<br>      "rulePriority": 1,<br>      "selection": {<br>        "countNumber": 7,<br>        "countType": "sinceImagePushed",<br>        "countUnit": "days",<br>        "tagStatus": "untagged"<br>      }<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_ecr_policy_statements"></a> [ecr\_policy\_statements](#input\_ecr\_policy\_statements) | (Optional). A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage. | `any` | `{}` | no |
| <a name="input_ecr_public_repository_catalog_data"></a> [ecr\_public\_repository\_catalog\_data](#input\_ecr\_public\_repository\_catalog\_data) | (Optional). Catalog data configuration for the repository | `any` | `{}` | no |
| <a name="input_ecr_registry_manage_scanning"></a> [ecr\_registry\_manage\_scanning](#input\_ecr\_registry\_manage\_scanning) | (Optional). Determines whether the registry scanning configuration will be managed. | `bool` | `false` | no |
| <a name="input_ecr_registry_policy"></a> [ecr\_registry\_policy](#input\_ecr\_registry\_policy) | (Optional). The policy document. This is a JSON formatted string | `string` | `null` | no |
| <a name="input_ecr_registry_pull_through_cache_rules"></a> [ecr\_registry\_pull\_through\_cache\_rules](#input\_ecr\_registry\_pull\_through\_cache\_rules) | (Optional). List of pull through cache rules to create | `map(map(string))` | `{}` | no |
| <a name="input_ecr_scan_rules"></a> [ecr\_scan\_rules](#input\_ecr\_scan\_rules) | (Optional). The rules for the registry scan. | <pre>list(object({<br>    scan_frequency = string<br>    filter = list(object({<br>      filter      = string<br>      filter_type = string<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "filter": [<br>      {<br>        "filter": "*",<br>        "filter_type": "WILDCARD"<br>      }<br>    ],<br>    "scan_frequency": "SCAN_ON_PUSH"<br>  }<br>]</pre> | no |
| <a name="input_ecr_scan_type"></a> [ecr\_scan\_type](#input\_ecr\_scan\_type) | (Optional). The type of scan to perform on the registry. | `string` | `"ENHANCED"` | no |
| <a name="input_env"></a> [env](#input\_env) | (Optional). Name of the current environment. | `string` | `"dev"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required). The name of the resource, application, or service. | `string` | n/a | yes |
| <a name="input_overrides"></a> [overrides](#input\_overrides) | A map of overrides to pass to the module that can be used by the local overrides | `map(any)` | `{}` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional). A aws\_iam\_policy\_document json encoded string to override the default repository policy. | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Optional). Prefix override for all generated naming conventions. | `string` | `"cs"` | no |
| <a name="input_private"></a> [private](#input\_private) | (Optional). Private or public repository?. When creating a public repository (private = false), the region must be set to 'us-east-1'. | `bool` | `true` | no |
| <a name="input_project"></a> [project](#input\_project) | (Optional). Name of the client project. | `string` | `"pmod"` | no |
| <a name="input_read"></a> [read](#input\_read) | (Optional). ARNs of resources or services to give read (pull) access to. Any Lambda ARNs will be automatically parsed and moved to `repository_lambda_read_access_arns`. | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional). Name of the region. | `string` | `"us-east-1"` | no |
| <a name="input_services"></a> [services](#input\_services) | (Optional). Toggle AWS service access on or off. | <pre>object({<br>    ecr       = optional(bool, false)<br>    eks       = optional(bool, false)<br>    codebuild = optional(bool, false)<br>    lambda    = optional(bool, false)<br>    beanstalk = optional(bool, false)<br>    sagemaker = optional(bool, false)<br>    batch     = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_ssm_parameter_name"></a> [ssm\_parameter\_name](#input\_ssm\_parameter\_name) | (Required). SSM parameter name to store resource ARN. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional). A map of tags to assign to the resources | `map(string)` | `null` | no |
| <a name="input_write"></a> [write](#input\_write) | (Optional). ARNs of resources or services to give write (push) access to. Write access also provides read access. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | n/a |
| <a name="output_repository_registry_id"></a> [repository\_registry\_id](#output\_repository\_registry\_id) | n/a |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | n/a |
<!-- END_TF_DOCS -->
