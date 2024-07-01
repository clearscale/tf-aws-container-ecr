module "ssm" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "~> 1.1.1"

  name  = coalesce(var.ssm_parameter_name, "/ecr/${var.env}/${local.name}")
  value = module.ecr.repository_arn

  tags = var.tags
}