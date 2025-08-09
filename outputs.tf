output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.cluster.eks_cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.cluster.eks_cluster_ca_cert
}

output "cluster_auth_token" {
  description = "Token to use for authentication with the cluster"
  value       = module.cluster.eks_cluster_auth_token
  sensitive   = true
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.cluster.cluster_arn
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the cluster"
  value       = module.cluster.cluster_oidc_issuer_url
}

output "addons_versions" {
  description = "Versions of managed addons"
  value       = module.addons.versions
}

output "addons_status" {
  description = "Status of managed addons"
  value       = module.addons.ids
}

# Node Groups Outputs
output "managed_node_group_arns" {
  description = "ARNs of managed node groups"
  value       = module.node_groups.managed_node_group_arns
}

output "managed_node_group_ids" {
  description = "IDs of managed node groups"
  value       = module.node_groups.managed_node_group_ids
}

output "managed_node_group_resources" {
  description = "Resource information for managed node groups"
  value       = module.node_groups.managed_node_group_resources
}

output "self_managed_node_group_launch_template_ids" {
  description = "Launch template IDs for self-managed node groups"
  value       = module.node_groups.self_managed_node_group_launch_template_ids
}

output "self_managed_node_group_asg_names" {
  description = "Auto scaling group names for self-managed node groups"
  value       = module.node_groups.self_managed_node_group_asg_names
}

output "managed_node_group_role_arns" {
  description = "ARNs of managed node group IAM roles"
  value       = module.node_groups.managed_node_group_role_arns
}

output "managed_node_group_role_names" {
  description = "Names of managed node group IAM roles"
  value       = module.node_groups.managed_node_group_role_names
}

output "self_managed_node_group_role_arns" {
  description = "ARNs of self-managed node group IAM roles"
  value       = module.node_groups.self_managed_node_group_role_arns
}

output "self_managed_node_group_role_names" {
  description = "Names of self-managed node group IAM roles"
  value       = module.node_groups.self_managed_node_group_role_names
}
