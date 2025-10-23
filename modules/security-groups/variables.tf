variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  ephemeral   = true
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
  ephemeral   = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  ephemeral   = true
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  ephemeral   = true
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
  ephemeral   = true
}