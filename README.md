# Core Infrastructure Stack

이 스택은 기본 인프라 리소스를 관리합니다. VPC, 보안 그룹, IAM 역할 등 다른 애플리케이션 스택에서 공통으로 사용하는 기본 인프라를 제공합니다.

## 📋 개요

- **스택 이름**: `core-infrastructure`
- **목적**: 기본 네트워크 인프라 및 보안 리소스 제공
- **리전**: `ap-northeast-2` (서울)
- **의존성**: Private Module Registry의 VPC 모듈

## 🏗️ 포함된 리소스

### 네트워크 리소스
- **VPC**: Private Module Registry 모듈 사용 (`app.terraform.io/rum-org-korean-air/vpc-for-test/aws`)
- **서브넷**: 퍼블릭/프라이빗 서브넷 (환경별 가용 영역 수 조정)
- **인터넷 게이트웨이**: 퍼블릭 서브넷 인터넷 연결
- **NAT 게이트웨이**: 프라이빗 서브넷 아웃바운드 연결 (환경별 설정)

### 보안 리소스
- **웹 보안 그룹**: HTTP/HTTPS/SSH 접근 제어
- **데이터베이스 보안 그룹**: MySQL/PostgreSQL 접근 제어
- **애플리케이션 보안 그룹**: 내부 통신용

### IAM 리소스
- **EC2 인스턴스 프로파일**: SSM, CloudWatch, S3 접근 권한
- **RDS 모니터링 역할**: Enhanced Monitoring용

## 📁 디렉토리 구조

```
terraform-stacks-core/
├── main.tfcomponent.hcl           # 스택 컴포넌트 정의
├── deployments.tfdeploy.hcl       # 환경별 배포 설정
├── .terraform-version             # Terraform 버전 고정
├── .gitignore                     # Git 무시 파일
├── README.md                      # 이 파일
├── components/
│   └── infrastructure/            # 인프라 컴포넌트
│       ├── main.tf                # 모듈 호출
│       ├── variables.tf           # 입력 변수
│       ├── outputs.tf             # 출력 값
│       └── providers.tf           # Provider 설정
├── modules/
│   ├── security-groups/           # 보안 그룹 모듈
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/                       # IAM 모듈
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── config/
    └── network-config.yaml        # 환경별 네트워크 설정
```

## 🌍 환경별 설정

### Development (dev)
- **VPC CIDR**: `10.0.0.0/16`
- **가용 영역**: `ap-northeast-2a` (1개)
- **NAT Gateway**: 비활성화 (비용 절약)

### Staging (stg)
- **VPC CIDR**: `10.1.0.0/16`
- **가용 영역**: `ap-northeast-2a`, `ap-northeast-2b` (2개)
- **NAT Gateway**: 활성화

### Production (prd)
- **VPC CIDR**: `10.2.0.0/16`
- **가용 영역**: `ap-northeast-2a`, `ap-northeast-2b`, `ap-northeast-2c` (3개)
- **NAT Gateway**: 활성화

## 📤 출력 값

이 스택은 다음 출력 값들을 `publish_output`으로 게시하여 다른 스택에서 사용할 수 있도록 합니다:

```hcl
vpc_outputs = {
  vpc_id                    = "vpc-xxxxx"
  vpc_cidr_block           = "10.x.0.0/16"
  public_subnet_ids         = ["subnet-xxxxx", ...]
  private_subnet_ids        = ["subnet-xxxxx", ...]
  web_security_group_id     = "sg-xxxxx"
  db_security_group_id      = "sg-xxxxx"
  app_security_group_id     = "sg-xxxxx"
  ec2_instance_profile_arn  = "arn:aws:iam::xxx:instance-profile/xxx"
  ec2_role_arn             = "arn:aws:iam::xxx:role/xxx"
}
```

## 🔧 필요한 Variable Sets

이 스택을 배포하기 위해 다음 Variable Sets가 필요합니다:

1. **aws-credentials**: AWS 인증 정보
2. **common-tags**: 공통 태그 설정
3. **network-config**: 환경별 네트워크 설정

## 🚀 배포 방법

### 1. Variable Sets 설정
Terraform Cloud에서 필요한 Variable Sets를 생성하고 설정합니다.

### 2. Private Module Registry 등록
VPC 모듈을 Private Module Registry에 등록합니다:
```
app.terraform.io/rum-org-korean-air/vpc-for-test/aws
```

### 3. 스택 배포
Terraform Cloud에서 스택을 생성하고 배포합니다:
1. 워크스페이스 생성
2. VCS 연결 (이 리포지토리)
3. Variable Sets 연결
4. 배포 실행

### 4. 배포 순서
```
dev → stg → prd (순차적 배포)
```

## 🏷️ 태그 전략

모든 리소스에 다음 태그가 자동으로 적용됩니다:

```hcl
{
  Environment = "dev|stg|prd"
  Project     = "terraform-stacks-demo"
  Owner       = "devops-team"
  CreatedBy   = "hj.do"
  CostCenter  = "engineering"
  ManagedBy   = "terraform-stacks"
  Stack       = "core-infrastructure"
}
```

## 🔍 모니터링

### CloudWatch 메트릭
- VPC Flow Logs (프로덕션 환경)
- NAT Gateway 메트릭
- 보안 그룹 사용량

### 비용 추적
- 태그 기반 비용 할당
- 환경별 비용 분석
- 리소스별 비용 추적

## 🛠️ 문제 해결

### 일반적인 문제

1. **Private Module 접근 오류**
   ```
   Error: Module not found
   ```
   - Private Module Registry에 모듈이 등록되었는지 확인
   - 조직 권한 확인

2. **Variable Set 참조 오류**
   ```
   Error: Reference to undeclared input variable
   ```
   - Variable Sets가 워크스페이스에 연결되었는지 확인
   - 변수명 오타 확인

3. **CIDR 블록 충돌**
   ```
   Error: InvalidVpc.Range
   ```
   - 환경별 CIDR 블록이 겹치지 않는지 확인
   - 기존 VPC와의 충돌 확인

## 📚 관련 문서

- [Terraform Stacks 공식 문서](https://developer.hashicorp.com/terraform/cloud-docs/stacks)
- [Private Module Registry 가이드](https://developer.hashicorp.com/terraform/cloud-docs/registry)
- [Variable Sets 설정 가이드](../terraform-cloud-setup/README.md)

## 🔄 업데이트 이력

- **v1.0.0**: 초기 버전 생성
- 서울 리전 (ap-northeast-2) 설정
- Private Module Registry VPC 모듈 연동