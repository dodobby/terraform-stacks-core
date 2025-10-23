# =============================================================================
# 기본 스택 컴포넌트 정의 (Core Infrastructure Stack)
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
    region = var.aws_region
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

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "hjdo"
  ephemeral   = true
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-2"
  ephemeral   = true
}

variable "project_name" {
  type        = string
  description = "Project name"
  ephemeral   = true
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
  ephemeral   = true
}

variable "createdBy" {
  type        = string
  description = "Creator of the resources"
  ephemeral   = true
}

variable "cost_center" {
  type        = string
  description = "Cost center"
  ephemeral   = true
}

variable "managed_by" {
  type        = string
  description = "Managed by"
  ephemeral   = true
}

# -----------------------------------------------------------------------------
# 로컬 값 및 설정
# -----------------------------------------------------------------------------
locals {
  # YAML 파일에서 설정 읽기 시도
  network_config = try(yamldecode(file("config/network-config.yaml")), {
    dev = { 
      vpc_cidr = "70.0.0.0/16", 
      availability_zones = ["ap-northeast-2a"],
      enable_nat_gateway = false
    }
    stg = { 
      vpc_cidr = "70.1.0.0/16", 
      availability_zones = ["ap-northeast-2a", "ap-northeast-2b"],
      enable_nat_gateway = true
    }
    prd = { 
      vpc_cidr = "70.2.0.0/16", 
      availability_zones = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"],
      enable_nat_gateway = true
    }
  })
  
  # 환경별 설정 추출
  current_config = try(local.network_config[var.environment], {
    vpc_cidr = var.vpc_cidr
    availability_zones = var.availability_zones
    enable_nat_gateway = true
  })
  
  # 테스트 결과 확인용
  yaml_load_success = can(yamldecode(file("config/network-config.yaml")))
  locals_block_success = true
  
  # 실제 사용할 값들 (YAML 우선, 실패 시 변수 사용)
  final_vpc_cidr = try(local.current_config.vpc_cidr, var.vpc_cidr)
  final_availability_zones = try(local.current_config.availability_zones, var.availability_zones)
  final_enable_nat_gateway = try(local.current_config.enable_nat_gateway, true)
  
  # Convert ephemeral variables to non-ephemeral
  final_name_prefix = var.name_prefix
  final_aws_region = var.aws_region
  final_managed_by = var.managed_by
  
  # 공통 태그
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = var.createdBy
    CostCenter  = var.cost_center
    ManagedBy   = local.final_managed_by
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
    environment         = var.environment
    vpc_cidr           = local.final_vpc_cidr
    availability_zones = local.final_availability_zones
    name_prefix        = local.final_name_prefix
    aws_region         = local.final_aws_region
    enable_nat_gateway = local.final_enable_nat_gateway
    common_tags        = local.common_tags
  }
}

# -----------------------------------------------------------------------------
# 출력 값 정의
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  type        = string
  value       = component.infrastructure.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  value       = component.infrastructure.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
  value       = component.infrastructure.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
  value       = component.infrastructure.private_subnet_ids
}

output "web_security_group_id" {
  description = "Web security group ID"
  type        = string
  value       = component.infrastructure.web_security_group_id
}

output "db_security_group_id" {
  description = "Database security group ID"
  type        = string
  value       = component.infrastructure.db_security_group_id
}

output "app_security_group_id" {
  description = "Application security group ID"
  type        = string
  value       = component.infrastructure.app_security_group_id
}

output "ec2_instance_profile_arn" {
  description = "EC2 instance profile ARN"
  type        = string
  value       = component.infrastructure.ec2_instance_profile_arn
}

output "ec2_role_arn" {
  description = "EC2 IAM role ARN"
  type        = string
  value       = component.infrastructure.ec2_role_arn
}

# -----------------------------------------------------------------------------
# 테스트 결과 출력
# -----------------------------------------------------------------------------
output "test_results" {
  description = "테스트 결과: locals 블록과 yamldecode 함수 지원 여부"
  type = object({
    locals_block_supported = bool
    yaml_file_loaded = bool
    vpc_cidr_source = string
    final_vpc_cidr = string
    final_availability_zones = list(string)
    final_enable_nat_gateway = bool
  })
  value = {
    locals_block_supported = local.locals_block_success
    yaml_file_loaded = local.yaml_load_success
    vpc_cidr_source = local.yaml_load_success ? "yaml" : "variable"
    final_vpc_cidr = local.final_vpc_cidr
    final_availability_zones = local.final_availability_zones
    final_enable_nat_gateway = local.final_enable_nat_gateway
  }
}