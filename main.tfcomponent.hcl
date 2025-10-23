# =============================================================================
# 기본 스택 컴포넌트 정의 (Core Infrastructure Stack)
# =============================================================================

# -----------------------------------------------------------------------------
# Provider 요구사항
# -----------------------------------------------------------------------------
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.17"
  }
}

# -----------------------------------------------------------------------------
# 입력 변수 정의
# -----------------------------------------------------------------------------
variable "environment" {
  type        = string
  description = "Environment name (dev, stg, prd)"
  
  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  
  validation {
    condition     = length(var.availability_zones) >= 1 && length(var.availability_zones) <= 3
    error_message = "Must specify between 1 and 3 availability zones."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "hjdo"
  
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 10
    error_message = "Name prefix must be between 1 and 10 characters."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
}

variable "created_by" {
  type        = string
  description = "Creator of the resources"
}

variable "cost_center" {
  type        = string
  description = "Cost center"
}

# -----------------------------------------------------------------------------
# 로컬 값 및 설정
# -----------------------------------------------------------------------------
locals {
  # YAML 파일에서 설정 읽기 시도
  network_config = try(yamldecode(file("${path.root}/config/network-config.yaml")), {
    dev = { 
      vpc_cidr = "10.0.0.0/16", 
      availability_zones = ["ap-northeast-2a"],
      enable_nat_gateway = false
    }
    stg = { 
      vpc_cidr = "10.1.0.0/16", 
      availability_zones = ["ap-northeast-2a", "ap-northeast-2b"],
      enable_nat_gateway = true
    }
    prd = { 
      vpc_cidr = "10.2.0.0/16", 
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
  yaml_load_success = can(yamldecode(file("${path.root}/config/network-config.yaml")))
  locals_block_success = true
  
  # 실제 사용할 값들 (YAML 우선, 실패 시 변수 사용)
  final_vpc_cidr = try(local.current_config.vpc_cidr, var.vpc_cidr)
  final_availability_zones = try(local.current_config.availability_zones, var.availability_zones)
  final_enable_nat_gateway = try(local.current_config.enable_nat_gateway, true)
  
  # 공통 태그
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = var.created_by
    CostCenter  = var.cost_center
    ManagedBy   = "terraform-stacks"
    Stack       = "core-infrastructure"
  }
}

# -----------------------------------------------------------------------------
# 컴포넌트 정의
# -----------------------------------------------------------------------------
component "infrastructure" {
  source = "./components/infrastructure"
  
  inputs = {
    environment         = var.environment
    vpc_cidr           = local.final_vpc_cidr
    availability_zones = local.final_availability_zones
    name_prefix        = var.name_prefix
    aws_region         = var.aws_region
    enable_nat_gateway = local.final_enable_nat_gateway
    common_tags        = local.common_tags
  }
}

# -----------------------------------------------------------------------------
# 출력 값 정의
# -----------------------------------------------------------------------------
output "vpc_id" {
  value       = component.infrastructure.vpc_id
  description = "VPC ID"
}

output "vpc_cidr_block" {
  value       = component.infrastructure.vpc_cidr_block
  description = "VPC CIDR block"
}

output "public_subnet_ids" {
  value       = component.infrastructure.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = component.infrastructure.private_subnet_ids
  description = "Private subnet IDs"
}

output "web_security_group_id" {
  value       = component.infrastructure.web_security_group_id
  description = "Web security group ID"
}

output "db_security_group_id" {
  value       = component.infrastructure.db_security_group_id
  description = "Database security group ID"
}

output "app_security_group_id" {
  value       = component.infrastructure.app_security_group_id
  description = "Application security group ID"
}

output "ec2_instance_profile_arn" {
  value       = component.infrastructure.ec2_instance_profile_arn
  description = "EC2 instance profile ARN"
}

output "ec2_role_arn" {
  value       = component.infrastructure.ec2_role_arn
  description = "EC2 IAM role ARN"
}

# -----------------------------------------------------------------------------
# 테스트 결과 출력
# -----------------------------------------------------------------------------
output "test_results" {
  value = {
    locals_block_supported = local.locals_block_success
    yaml_file_loaded = local.yaml_load_success
    vpc_cidr_source = local.yaml_load_success ? "yaml" : "variable"
    final_vpc_cidr = local.final_vpc_cidr
    final_availability_zones = local.final_availability_zones
    final_enable_nat_gateway = local.final_enable_nat_gateway
  }
  description = "테스트 결과: locals 블록과 yamldecode 함수 지원 여부"
}