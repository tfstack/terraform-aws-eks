locals {
  ids_map = {
    coredns   = try(aws_eks_addon.coredns[0].id, null)
    kubeproxy = try(aws_eks_addon.kube_proxy[0].id, null)
    vpc_cni   = try(aws_eks_addon.vpc_cni[0].id, null)
    ebs_csi   = try(aws_eks_addon.ebs_csi[0].id, null)
    efs_csi   = try(aws_eks_addon.efs_csi[0].id, null)
  }

  versions_map = {
    coredns   = try(aws_eks_addon.coredns[0].addon_version, null)
    kubeproxy = try(aws_eks_addon.kube_proxy[0].addon_version, null)
    vpc_cni   = try(aws_eks_addon.vpc_cni[0].addon_version, null)
    ebs_csi   = try(aws_eks_addon.ebs_csi[0].addon_version, null)
    efs_csi   = try(aws_eks_addon.efs_csi[0].addon_version, null)
  }
}

output "ids" {
  description = "Addon IDs keyed by addon name (null if disabled)"
  value       = local.ids_map
}

output "versions" {
  description = "Addon versions keyed by addon name (null if disabled)"
  value       = local.versions_map
}
