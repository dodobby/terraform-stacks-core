# Private Module Registry VPC 모듈 사용
module "vpc-for-test" {
  source  = "app.terraform.io/rum-org-korean-air/vpc-for-test/aws"
  version = "1.0.0"

  name_prefix        = var.name_prefix
  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  enable_nat_gateway = var.enable_nat_gateway
  tags = var.common_tags
}

# 보안 그룹 모듈
module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix = var.name_prefix
  environment = var.environment
  vpc_id      = module.vpc-for-test.vpc_id
  vpc_cidr    = module.vpc-for-test.vpc_cidr_block
  tags = var.common_tags
}

# IAM 모듈
module "iam" {
  source = "../../modules/iam"

  name_prefix = var.name_prefix
  environment = var.environment
  tags = var.common_tags
}