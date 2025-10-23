# 웹 서버용 보안 그룹
resource "aws_security_group" "web" {
  name_prefix = "${var.name_prefix}-core-sg-web-${var.environment}-"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-core-sg-web-${var.environment}"
    Type = "web"
  })
}

# 웹 서버 인바운드 규칙 - HTTP
resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP from anywhere"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
  tags = {
    Name = "web-http-inbound"
  }
}

# 웹 서버 인바운드 규칙 - HTTPS
resource "aws_vpc_security_group_ingress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  description       = "HTTPS from anywhere"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  tags = {
    Name = "web-https-inbound"
  }
}

# 웹 서버 인바운드 규칙 - SSH (VPC 내부만)
resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH from VPC"
  cidr_ipv4   = var.vpc_cidr
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
  tags = {
    Name = "web-ssh-inbound"
  }
}

# 웹 서버 아웃바운드 규칙 - 모든 트래픽
resource "aws_vpc_security_group_egress_rule" "web_all_outbound" {
  security_group_id = aws_security_group.web.id
  description       = "All outbound traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  tags = {
    Name = "web-all-outbound"
  }
}

# 데이터베이스용 보안 그룹
resource "aws_security_group" "db" {
  name_prefix = "${var.name_prefix}-core-sg-db-${var.environment}-"
  description = "Security group for database servers"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-core-sg-db-${var.environment}"
    Type = "database"
  })
}

# 데이터베이스 인바운드 규칙 - MySQL/Aurora
resource "aws_vpc_security_group_ingress_rule" "db_mysql" {
  security_group_id = aws_security_group.db.id
  description       = "MySQL/Aurora from web servers"
  referenced_security_group_id = aws_security_group.web.id
  from_port                   = 3306
  ip_protocol                 = "tcp"
  to_port                     = 3306
  tags = {
    Name = "db-mysql-inbound"
  }
}

# 데이터베이스 인바운드 규칙 - PostgreSQL
resource "aws_vpc_security_group_ingress_rule" "db_postgresql" {
  security_group_id = aws_security_group.db.id
  description       = "PostgreSQL from web servers"
  referenced_security_group_id = aws_security_group.web.id
  from_port                   = 5432
  ip_protocol                 = "tcp"
  to_port                     = 5432
  tags = {
    Name = "db-postgresql-inbound"
  }
}

# 애플리케이션용 보안 그룹 (내부 통신용)
resource "aws_security_group" "app" {
  name_prefix = "${var.name_prefix}-core-sg-app-${var.environment}-"
  description = "Security group for application servers"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-core-sg-app-${var.environment}"
    Type = "application"
  })
}

# 애플리케이션 인바운드 규칙 - 내부 통신
resource "aws_vpc_security_group_ingress_rule" "app_internal" {
  security_group_id = aws_security_group.app.id
  description       = "Internal communication"
  cidr_ipv4   = var.vpc_cidr
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
  tags = {
    Name = "app-internal-inbound"
  }
}

# 애플리케이션 아웃바운드 규칙 - 모든 트래픽
resource "aws_vpc_security_group_egress_rule" "app_all_outbound" {
  security_group_id = aws_security_group.app.id
  description       = "All outbound traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  tags = {
    Name = "app-all-outbound"
  }
}