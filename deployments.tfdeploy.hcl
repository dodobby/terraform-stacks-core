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
  inputs = {
    # 환경 구분
    environment = "dev"
    
    # AWS 자격증명 (Variable Sets에서 가져오기)
    aws_access_key_id     = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    aws_secret_access_key = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
    
    # 공통 설정
    aws_region    = "ap-northeast-2"
    project_name  = "terraform-stacks-demo"
    owner         = "devops-team"
    createdBy     = "hj.do"
    cost_center   = "engineering"
    managed_by    = "terraform-stacks"
    name_prefix   = "hjdo"
  }
  
  deployment_group = deployment_group.core_development
}

# 스테이징 환경 배포
deployment "stg" {
  inputs = {
    # 환경 구분
    environment = "stg"
    
    # AWS 자격증명 (Variable Sets에서 가져오기)
    aws_access_key_id     = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    aws_secret_access_key = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
    
    # 공통 설정
    aws_region    = "ap-northeast-2"
    project_name  = "terraform-stacks-demo"
    owner         = "devops-team"
    createdBy     = "hj.do"
    cost_center   = "engineering"
    managed_by    = "terraform-stacks"
    name_prefix   = "hjdo"
  }
  
  deployment_group = deployment_group.core_staging
}

# 프로덕션 환경 배포
deployment "prd" {
  inputs = {
    # 환경 구분
    environment = "prd"
    
    # AWS 자격증명 (Variable Sets에서 가져오기)
    aws_access_key_id     = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    aws_secret_access_key = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
    
    # 공통 설정
    aws_region    = "ap-northeast-2"
    project_name  = "terraform-stacks-demo"
    owner         = "devops-team"
    createdBy     = "hj.do"
    cost_center   = "engineering"
    managed_by    = "terraform-stacks"
    name_prefix   = "hjdo"
  }
  
  deployment_group = deployment_group.core_production
}

# -----------------------------------------------------------------------------
# 출력값 발행 - 다른 스택에서 참조 가능하도록 설정
# -----------------------------------------------------------------------------
publish_output "vpc_outputs" {
  description = "VPC and networking outputs for dev environment"
  type = object({
    vpc_id                   = string
    public_subnet_ids        = list(string)
    private_subnet_ids       = list(string)
    web_security_group_id    = string
    db_security_group_id     = string
    ec2_instance_profile_arn = string
  })
}

publish_output "stg_vpc_outputs" {
  description = "VPC and networking outputs for stg environment"
  type = object({
    vpc_id                   = string
    public_subnet_ids        = list(string)
    private_subnet_ids       = list(string)
    web_security_group_id    = string
    db_security_group_id     = string
    ec2_instance_profile_arn = string
  })
}

publish_output "prd_vpc_outputs" {
  description = "VPC and networking outputs for prd environment"
  type = object({
    vpc_id                   = string
    public_subnet_ids        = list(string)
    private_subnet_ids       = list(string)
    web_security_group_id    = string
    db_security_group_id     = string
    ec2_instance_profile_arn = string
  })
}

publish_output "yaml_config_test" {
  description = "YAML 파일 decode 테스트 결과"
  type = object({
    yaml_loaded = bool
    current_environment = string
    vpc_cidr_from_yaml = string
    availability_zones_from_yaml = list(string)
    enable_nat_gateway_from_yaml = bool
  })
}