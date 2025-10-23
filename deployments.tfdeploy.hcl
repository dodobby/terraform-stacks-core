# =============================================================================
# 기본 스택 배포 정의 (Core Infrastructure Stack Deployments)
# =============================================================================

# -----------------------------------------------------------------------------
# Variable Sets 참조 - AWS 인증은 Variable Sets를 통해 관리
# -----------------------------------------------------------------------------
store "varset" "aws_credentials" {
  id       = "varset-aws-credentials-id"  # 실제 Variable Set ID로 교체 필요
  category = "terraform"
}

store "varset" "common_tags" {
  id       = "varset-common-tags-id"  # 실제 Variable Set ID로 교체 필요
  category = "terraform"
}

store "varset" "network_config" {
  id       = "varset-network-config-id"  # 실제 Variable Set ID로 교체 필요
  category = "terraform"
}

# -----------------------------------------------------------------------------
# 배포 그룹 정의 - 환경별 배포 순서 제어
# -----------------------------------------------------------------------------
deployment_group "development" {
  deployments = ["dev"]
}

deployment_group "staging" {
  deployments = ["stg"]
  depends_on = [deployment_group.development]
}

deployment_group "production" {
  deployments = ["prd"]
  depends_on = [deployment_group.staging]
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
    created_by    = store.varset.common_tags.created_by
    cost_center   = store.varset.common_tags.cost_center
    name_prefix   = store.varset.common_tags.name_prefix
  }
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
    created_by    = store.varset.common_tags.created_by
    cost_center   = store.varset.common_tags.cost_center
    name_prefix   = store.varset.common_tags.name_prefix
  }
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
    created_by    = store.varset.common_tags.created_by
    cost_center   = store.varset.common_tags.cost_center
    name_prefix   = store.varset.common_tags.name_prefix
  }
}

# -----------------------------------------------------------------------------
# 자동 승인 정책
# -----------------------------------------------------------------------------
deployment_auto_approve "dev_auto_approve" {
  deployment = "dev"
  
  condition {
    max_changes = 10
    reason = "Dev environment - auto approved for small changes"
  }
}

# stg, prd 환경은 수동 승인 (기본값)

# -----------------------------------------------------------------------------
# 출력 값 게시 - 다른 스택에서 사용
# -----------------------------------------------------------------------------
publish_output "vpc_outputs" {
  outputs = {
    vpc_id                    = output.vpc_id
    vpc_cidr_block           = output.vpc_cidr_block
    public_subnet_ids         = output.public_subnet_ids
    private_subnet_ids        = output.private_subnet_ids
    web_security_group_id     = output.web_security_group_id
    db_security_group_id      = output.db_security_group_id
    app_security_group_id     = output.app_security_group_id
    ec2_instance_profile_arn  = output.ec2_instance_profile_arn
    ec2_role_arn             = output.ec2_role_arn
  }
}