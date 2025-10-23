# =============================================================================
# 기본 스택 배포 정의 (Core Infrastructure Stack Deployments)
# =============================================================================

# -----------------------------------------------------------------------------
# Variable Sets 참조 - AWS 인증은 Variable Sets를 통해 관리
# -----------------------------------------------------------------------------
store "varset" "aws_credentials" {
  id       = "varset-VqTt9ubP3LPSFKeS"
  category = "terraform"
}

store "varset" "common_tags" {
  id       = "varset-vMFB9eJBNwQpDhBo"
  category = "terraform"
}

store "varset" "network_config" {
  id       = "varset-eLGwZg8NBefZorr9"
  category = "terraform"
}

# -----------------------------------------------------------------------------
# 자동 승인 정책 정의
# -----------------------------------------------------------------------------
deployment_auto_approve "dev_auto_approve" {
  check {
    condition = context.plan.deployment == deployment.dev
    reason    = "Automatically applying dev deployment for small changes."
  }
}

deployment_auto_approve "small_changes" {
  check {
    condition = context.plan.changes.total <= 10
    reason    = "Auto-approve changes with 10 or fewer resources."
  }
}

# -----------------------------------------------------------------------------
# 배포 그룹 정의 - 환경별 배포 순서 제어
# -----------------------------------------------------------------------------
deployment_group "development" {
  auto_approve_checks = [
    deployment_auto_approve.dev_auto_approve,
    deployment_auto_approve.small_changes
  ]
}

deployment_group "staging" {
  auto_approve_checks = []  # 수동 승인
}

deployment_group "production" {
  auto_approve_checks = []  # 수동 승인
}

# -----------------------------------------------------------------------------
# 환경별 배포 정의
# -----------------------------------------------------------------------------

# 개발 환경 배포
deployment "dev" {
  inputs = {
    # 환경 구분
    environment = "dev"
    
    # 네트워크 설정 (Variable Sets에서 관리)
    vpc_cidr           = store.varset.network_config.dev_vpc_cidr
    availability_zones = store.varset.network_config.dev_availability_zones
    
    # 공통 설정 (Variable Sets에서 관리)
    aws_region    = store.varset.aws_credentials.aws_region
    project_name  = store.varset.common_tags.project_name
    owner         = store.varset.common_tags.owner
    createdBy     = store.varset.common_tags.createdBy
    cost_center   = store.varset.common_tags.cost_center
    name_prefix   = store.varset.common_tags.name_prefix
  }
  
  deployment_group = deployment_group.development
}

# 스테이징 환경 배포
deployment "stg" {
  inputs = {
    # 환경 구분
    environment = "stg"
    
    # 네트워크 설정 (Variable Sets에서 관리)
    vpc_cidr           = store.varset.network_config.stg_vpc_cidr
    availability_zones = store.varset.network_config.stg_availability_zones
    
    # 공통 설정 (Variable Sets에서 관리)
    aws_region    = store.varset.aws_credentials.aws_region
    project_name  = store.varset.common_tags.project_name
    owner         = store.varset.common_tags.owner
    createdBy     = store.varset.common_tags.createdBy
    cost_center   = store.varset.common_tags.cost_center
    name_prefix   = store.varset.common_tags.name_prefix
  }
  
  deployment_group = deployment_group.staging
}

# 프로덕션 환경 배포
deployment "prd" {
  inputs = {
    # 환경 구분
    environment = "prd"
    
    # 네트워크 설정 (Variable Sets에서 관리)
    vpc_cidr           = store.varset.network_config.prd_vpc_cidr
    availability_zones = store.varset.network_config.prd_availability_zones
    
    # 공통 설정 (Variable Sets에서 관리)
    aws_region    = store.varset.aws_credentials.aws_region
    project_name  = store.varset.common_tags.project_name
    owner         = store.varset.common_tags.owner
    createdBy     = store.varset.common_tags.createdBy
    cost_center   = store.varset.common_tags.cost_center
    name_prefix   = store.varset.common_tags.name_prefix
  }
  
  deployment_group = deployment_group.production
}

# -----------------------------------------------------------------------------
# 출력 값 게시 - 다른 스택에서 사용
# -----------------------------------------------------------------------------
publish_output "vpc_outputs" {
  description = "VPC and network resources from core infrastructure"
  value = {
    vpc_id                    = deployment.dev.vpc_id
    vpc_cidr_block           = deployment.dev.vpc_cidr_block
    public_subnet_ids         = deployment.dev.public_subnet_ids
    private_subnet_ids        = deployment.dev.private_subnet_ids
    web_security_group_id     = deployment.dev.web_security_group_id
    db_security_group_id      = deployment.dev.db_security_group_id
    app_security_group_id     = deployment.dev.app_security_group_id
    ec2_instance_profile_arn  = deployment.dev.ec2_instance_profile_arn
    ec2_role_arn             = deployment.dev.ec2_role_arn
  }
}

publish_output "stg_vpc_outputs" {
  description = "VPC and network resources from staging environment"
  value = {
    vpc_id                    = deployment.stg.vpc_id
    vpc_cidr_block           = deployment.stg.vpc_cidr_block
    public_subnet_ids         = deployment.stg.public_subnet_ids
    private_subnet_ids        = deployment.stg.private_subnet_ids
    web_security_group_id     = deployment.stg.web_security_group_id
    db_security_group_id      = deployment.stg.db_security_group_id
    app_security_group_id     = deployment.stg.app_security_group_id
    ec2_instance_profile_arn  = deployment.stg.ec2_instance_profile_arn
    ec2_role_arn             = deployment.stg.ec2_role_arn
  }
}

publish_output "prd_vpc_outputs" {
  description = "VPC and network resources from production environment"
  value = {
    vpc_id                    = deployment.prd.vpc_id
    vpc_cidr_block           = deployment.prd.vpc_cidr_block
    public_subnet_ids         = deployment.prd.public_subnet_ids
    private_subnet_ids        = deployment.prd.private_subnet_ids
    web_security_group_id     = deployment.prd.web_security_group_id
    db_security_group_id      = deployment.prd.db_security_group_id
    app_security_group_id     = deployment.prd.app_security_group_id
    ec2_instance_profile_arn  = deployment.prd.ec2_instance_profile_arn
    ec2_role_arn             = deployment.prd.ec2_role_arn
  }
}