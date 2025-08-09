output "cluster_name" {
  description = "Cluster name"
  value       = try(aws_eks_cluster.this[0].name, null)
}

output "cluster_arn" {
  description = "Cluster ARN"
  value       = try(aws_eks_cluster.this[0].arn, null)
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL"
  value       = try(aws_eks_cluster.this[0].identity[0].oidc[0].issuer, null)
}

output "eks_cluster_endpoint" {
  description = "Cluster endpoint"
  value       = try(aws_eks_cluster.this[0].endpoint, null)
}

output "eks_cluster_ca_cert" {
  description = "Base64-decoded cluster CA cert"
  value       = try(base64decode(aws_eks_cluster.this[0].certificate_authority[0].data), null)
}

output "eks_cluster_auth_token" {
  description = "Authentication token"
  value       = try(data.aws_eks_cluster_auth.this[0].token, null)
  sensitive   = true
}
