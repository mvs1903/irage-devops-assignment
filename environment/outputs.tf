

output "vpc_ids" {
  description = "List of VPC IDs by key"
  value       = { for k, v in module.vpc : k => v.vpc_id }
}

output "public_subnet_ids" {
  description = "Public subnet IDs per VPC"
  value       = { for k, v in module.vpc : k => v.public_subnets }
}

output "private_subnet_ids" {
  description = "Private subnet IDs per VPC"
  value       = { for k, v in module.vpc : k => v.private_subnets }
}

output "bastion_public_ips" {
  description = "Public IPs of bastion hosts"
  value       = { for k, v in module.bastion : k => v.public_ip }
}

output "rds_endpoints" {
  description = "RDS instance endpoints"
  value       = { for k, v in module.rds_inst : k => v.db_instance_endpoint }
}

output "rds_instance_ids" {
  description = "RDS instance IDs"
  value       = { for k, v in module.rds_inst : k => v.db_instance_identifier }
}
