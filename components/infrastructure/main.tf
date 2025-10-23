# Convert ephemeral values to non-ephemeral using locals
locals {
  name_prefix        = var.name_prefix
  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  enable_nat_gateway = var.enable_nat_gateway
  common_tags       = var.common_tags
}

# Private Module Registry VPC 모듈 사용
module "vpc-for-test" {
  source  = "app.terraform.io/rum-org-korean-air/vpc-for-test/aws"
  version = "1.0.1"

  name_prefix        = local.name_prefix
  environment        = local.environment
  vpc_cidr          = local.vpc_cidr
  availability_zones = local.availability_zones
  enable_nat_gateway = local.enable_nat_gateway
  tags = local.common_tags
}

# 보안 그룹 모듈
module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix = local.name_prefix
  environment = local.environment
  vpc_id      = module.vpc-for-test.vpc_id
  vpc_cidr    = module.vpc-for-test.vpc_cidr_block
  tags = local.common_tags
}

# IAM 모듈
module "iam" {
  source = "../../modules/iam"

  name_prefix = local.name_prefix
  environment = local.environment
  tags = local.common_tags
}