# YAML 파일에서 네트워크 설정 읽기
locals {
  # YAML 파일 decode
  network_config = try(yamldecode(file("${path.module}/../../config/network-config.yaml")), {})
  
  # 현재 환경의 설정 추출
  current_config = try(local.network_config[var.environment], {
    vpc_cidr = var.vpc_cidr
    availability_zones = var.availability_zones
    enable_nat_gateway = var.enable_nat_gateway
    public_subnets = []
    private_subnets = []
  })
  
  # 최종 사용할 값들 (YAML 우선, 실패 시 변수 사용)
  name_prefix        = var.name_prefix
  environment        = var.environment
  vpc_cidr          = try(local.current_config.vpc_cidr, var.vpc_cidr)
  availability_zones = try(local.current_config.availability_zones, var.availability_zones)
  enable_nat_gateway = try(local.current_config.enable_nat_gateway, var.enable_nat_gateway)
  public_subnets     = try(local.current_config.public_subnets, [])
  private_subnets    = try(local.current_config.private_subnets, [])
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