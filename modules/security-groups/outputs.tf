output "web_security_group_id" {
  description = "Web security group ID"
  value       = aws_security_group.web.id
}

output "db_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.db.id
}

output "app_security_group_id" {
  description = "Application security group ID"
  value       = aws_security_group.app.id
}

output "web_security_group_arn" {
  description = "Web security group ARN"
  value       = aws_security_group.web.arn
}

output "db_security_group_arn" {
  description = "Database security group ARN"
  value       = aws_security_group.db.arn
}

output "app_security_group_arn" {
  description = "Application security group ARN"
  value       = aws_security_group.app.arn
}