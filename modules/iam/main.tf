# EC2 인스턴스용 IAM 역할
resource "aws_iam_role" "ec2_role" {
  name_prefix = "${var.name_prefix}-core-role-ec2-${var.environment}-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-core-role-ec2-${var.environment}"
    Type = "ec2-role"
  })
}

# EC2 기본 정책 연결 (SSM 관리용)
resource "aws_iam_role_policy_attachment" "ec2_ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch 에이전트 정책 연결
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# S3 접근을 위한 커스텀 정책
resource "aws_iam_policy" "ec2_s3_access" {
  name_prefix = "${var.name_prefix}-core-policy-s3-${var.environment}-"
  description = "Policy for EC2 instances to access S3 buckets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-app-*",
          "arn:aws:s3:::${var.name_prefix}-app-*/*"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-core-policy-s3-${var.environment}"
    Type = "s3-access-policy"
  })
}

# S3 정책을 EC2 역할에 연결
resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_access.arn
}

# EC2 인스턴스 프로파일
resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "${var.name_prefix}-core-profile-ec2-${var.environment}-"
  role        = aws_iam_role.ec2_role.name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-core-profile-ec2-${var.environment}"
    Type = "ec2-instance-profile"
  })
}

# RDS 모니터링용 IAM 역할 (Enhanced Monitoring용)
resource "aws_iam_role" "rds_monitoring_role" {
  name_prefix = "${var.name_prefix}-core-role-rds-monitoring-${var.environment}-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-core-role-rds-monitoring-${var.environment}"
    Type = "rds-monitoring-role"
  })
}

# RDS Enhanced Monitoring 정책 연결
resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}