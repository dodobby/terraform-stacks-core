# VPC 출력
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc-for-test.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc-for-test.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc-for-test.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc-for-test.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc-for-test.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc-for-test.nat_gateway_ids
}

# 보안 그룹 출력
output "web_security_group_id" {
  description = "Web security group ID"
  value       = module.security_groups.web_security_group_id
}

output "db_security_group_id" {
  description = "Database security group ID"
  value       = module.security_groups.db_security_group_id
}

output "app_security_group_id" {
  description = "Application security group ID"
  value       = module.security_groups.app_security_group_id
}

# IAM 출력
output "ec2_instance_profile_arn" {
  description = "EC2 instance profile ARN"
  value       = module.iam.ec2_instance_profile_arn
}

output "ec2_role_arn" {
  description = "EC2 IAM role ARN"
  value       = module.iam.ec2_role_arn
}

# -----------------------------------------------------------------------------
# YAML Decode 테스트 결과 출력
# -----------------------------------------------------------------------------
output "yaml_loaded" {
  description = "YAML 파일이 성공적으로 로드되었는지 여부"
  value       = can(yamldecode(file("${path.module}/../../config/network-config.yaml")))
}

output "vpc_cidr_from_yaml" {
  description = "YAML에서 읽은 VPC CIDR"
  value       = local.vpc_cidr
}

output "availability_zones_from_yaml" {
  description = "YAML에서 읽은 가용 영역"
  value       = local.availability_zones
}

output "enable_nat_gateway_from_yaml" {
  description = "YAML에서 읽은 NAT Gateway 설정"
  value       = local.enable_nat_gateway
}