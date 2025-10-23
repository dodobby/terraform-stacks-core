# =============================================================================
# Core Infrastructure Stack Deployments
# =============================================================================

# -----------------------------------------------------------------------------
# Variable Sets 참조
# -----------------------------------------------------------------------------
store "varset" "aws_credentials" {
  id       = "varset-VqTt9ubP3LPSFKeS"
  category = "env"
}

# -----------------------------------------------------------------------------
# 공통 설정 - 중앙 관리
# -----------------------------------------------------------------------------
locals {
  # 프로젝트 공통 설정
  common_config = {
    aws_region    = "ap-northeast-2"
    project_name  = "terraform-stacks-demo"
    owner         = "devops-team"
    createdBy     = "hj.do"
    cost_center   = "engineering"
    managed_by    = "terraform-stacks"
    name_prefix   = "hjdo"
  }
}

# -----------------------------------------------------------------------------
# 자동 승인 정책 정의
# -----------------------------------------------------------------------------
deployment_auto_approve "dev_auto_approve" {
  check {
    condition = context.plan != null && context.plan.deployment != null && context.plan.deployment == deployment.dev
    reason    = "Automatically applying dev deployment for core infrastructure."
  }
}

deployment_auto_approve "small_changes" {
  check {
    condition = context.plan != null && context.plan.changes != null && context.plan.changes.total <= 3
    reason    = "Auto-approve small infrastructure changes."
  }
}

# -----------------------------------------------------------------------------
# 배포 그룹 정의
# -----------------------------------------------------------------------------
deployment_group "core_development" {
  auto_approve_checks = [
    deployment_auto_approve.dev_auto_approve,
    deployment_auto_approve.small_changes
  ]
}

deployment_group "core_staging" {
  auto_approve_checks = []  # 수동 승인
}

deployment_group "core_production" {
  auto_approve_checks = []  # 수동 승인
}

# -----------------------------------------------------------------------------
# 환경별 배포 정의
# -----------------------------------------------------------------------------

# 개발 환경 배포
deployment "dev" {
  inputs = merge(local.common_config, {
    # 환경별 설정
    environment = "dev"
    
    # AWS 자격증명 (Variable Sets에서 가져오기)
    aws_access_key_id     = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    aws_secret_access_key = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
  })
  
  deployment_group = deployment_group.core_development
}

# 스테이징 환경 배포
deployment "stg" {
  inputs = merge(local.common_config, {
    # 환경별 설정
    environment = "stg"
    
    # AWS 자격증명 (Variable Sets에서 가져오기)
    aws_access_key_id     = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    aws_secret_access_key = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
  })
  
  deployment_group = deployment_group.core_staging
}

# 프로덕션 환경 배포
deployment "prd" {
  inputs = merge(local.common_config, {
    # 환경별 설정
    environment = "prd"
    
    # AWS 자격증명 (Variable Sets에서 가져오기)
    aws_access_key_id     = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    aws_secret_access_key = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
  })
  
  deployment_group = deployment_group.core_production
}