variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
  ephemeral   = true
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  ephemeral   = true
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  ephemeral   = true
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "hjdo"
  ephemeral   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
  ephemeral   = true
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
  ephemeral   = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
  ephemeral   = true
}