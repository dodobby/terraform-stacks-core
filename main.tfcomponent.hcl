# =============================================================================
# Core Infrastructure Stack (VPC, Subnets, Security Groups, IAM)
# =============================================================================

# -----------------------------------------------------------------------------
# Provider 요구사항
# -----------------------------------------------------------------------------
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.70"
  }
}

# -----------------------------------------------------------------------------
# Provider 설정
# -----------------------------------------------------------------------------
provider "aws" "default" {
  config {
    access_key = var.aws_access_key_id
    secret_key = var.aws_secret_access_key
    region     = var.aws_region
    default_tags {
      tags = {
        Environment = var.environment
        Project     = var.project_name
        Owner       = var.owner
        CreatedBy   = var.createdBy
        CostCenter  = var.cost_center
        ManagedBy   = var.managed_by
        Stack       = "core-infrastructure"
      }
    }
  }
}

# -----------------------------------------------------------------------------
# 입력 변수 정의
# -----------------------------------------------------------------------------
variable "environment" {
  type        = string
  description = "Environment name (dev, stg, prd)"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "hjdo"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key ID"
  sensitive   = true
  ephemeral   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
  sensitive   = true
  ephemeral   = true
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
}

variable "createdBy" {
  type        = string
  description = "Creator of the resources"
}

variable "cost_center" {
  type        = string
  description = "Cost center"
}

variable "managed_by" {
  type        = string
  description = "Managed by"
}

# -----------------------------------------------------------------------------
# 로컬 값 정의
# -----------------------------------------------------------------------------
locals {
  # VPC CIDR 블록 (기존 70.x.x.x 대역 사용)
  vpc_cidr = "70.0.0.0/16"
  
  # 공통 태그
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = var.createdBy
    CostCenter  = var.cost_center
    ManagedBy   = var.managed_by
    Stack       = "core-infrastructure"
  }
}

# -----------------------------------------------------------------------------
# 컴포넌트 정의
# -----------------------------------------------------------------------------
component "infrastructure" {
  source = "./components/infrastructure"
  
  providers = {
    aws = provider.aws.default
  }
  
  inputs = {
    environment        = var.environment
    name_prefix        = var.name_prefix
    vpc_cidr           = local.vpc_cidr
    availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
    enable_nat_gateway = true
    common_tags        = local.common_tags
  }
}

# -----------------------------------------------------------------------------
# 출력 값 정의
# -----------------------------------------------------------------------------
output "vpc_outputs" {
  description = "VPC and networking outputs for dev environment"
  type = object({
    vpc_id                   = string
    public_subnet_ids        = list(string)
    private_subnet_ids       = list(string)
    web_security_group_id    = string
    db_security_group_id     = string
    ec2_instance_profile_arn = string
  })
  value = {
    vpc_id                   = component.infrastructure.vpc_id
    public_subnet_ids        = component.infrastructure.public_subnet_ids
    private_subnet_ids       = component.infrastructure.private_subnet_ids
    web_security_group_id    = component.infrastructure.web_security_group_id
    db_security_group_id     = component.infrastructure.db_security_group_id
    ec2_instance_profile_arn = component.infrastructure.ec2_instance_profile_arn
  }
}

output "stg_vpc_outputs" {
  description = "VPC and networking outputs for stg environment"
  type = object({
    vpc_id                   = string
    public_subnet_ids        = list(string)
    private_subnet_ids       = list(string)
    web_security_group_id    = string
    db_security_group_id     = string
    ec2_instance_profile_arn = string
  })
  value = {
    vpc_id                   = component.infrastructure.vpc_id
    public_subnet_ids        = component.infrastructure.public_subnet_ids
    private_subnet_ids       = component.infrastructure.private_subnet_ids
    web_security_group_id    = component.infrastructure.web_security_group_id
    db_security_group_id     = component.infrastructure.db_security_group_id
    ec2_instance_profile_arn = component.infrastructure.ec2_instance_profile_arn
  }
}

output "prd_vpc_outputs" {
  description = "VPC and networking outputs for prd environment"
  type = object({
    vpc_id                   = string
    public_subnet_ids        = list(string)
    private_subnet_ids       = list(string)
    web_security_group_id    = string
    db_security_group_id     = string
    ec2_instance_profile_arn = string
  })
  value = {
    vpc_id                   = component.infrastructure.vpc_id
    public_subnet_ids        = component.infrastructure.public_subnet_ids
    private_subnet_ids       = component.infrastructure.private_subnet_ids
    web_security_group_id    = component.infrastructure.web_security_group_id
    db_security_group_id     = component.infrastructure.db_security_group_id
    ec2_instance_profile_arn = component.infrastructure.ec2_instance_profile_arn
  }
}

# -----------------------------------------------------------------------------
# YAML Decode 테스트 결과 출력
# -----------------------------------------------------------------------------
output "yaml_config_test" {
  description = "YAML 파일 decode 테스트 결과"
  type = object({
    yaml_loaded = bool
    current_environment = string
    vpc_cidr_from_yaml = string
    availability_zones_from_yaml = list(string)
    enable_nat_gateway_from_yaml = bool
  })
  value = {
    yaml_loaded = component.infrastructure.yaml_loaded
    current_environment = var.environment
    vpc_cidr_from_yaml = component.infrastructure.vpc_cidr_from_yaml
    availability_zones_from_yaml = component.infrastructure.availability_zones_from_yaml
    enable_nat_gateway_from_yaml = component.infrastructure.enable_nat_gateway_from_yaml
  }
}