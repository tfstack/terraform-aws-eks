locals {
  enabled = var.create
}

resource "aws_eks_addon" "coredns" {
  count                       = local.enabled && var.enable_coredns ? 1 : 0
  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  addon_version               = (var.coredns_version != null && var.coredns_version != "" && var.coredns_version != "latest") ? var.coredns_version : null
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  count                       = local.enabled && var.enable_kube_proxy ? 1 : 0
  cluster_name                = var.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = (var.kube_proxy_version != null && var.kube_proxy_version != "" && var.kube_proxy_version != "latest") ? var.kube_proxy_version : null
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}

resource "aws_eks_addon" "vpc_cni" {
  count                       = local.enabled && var.enable_vpc_cni ? 1 : 0
  cluster_name                = var.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = (var.vpc_cni_version != null && var.vpc_cni_version != "" && var.vpc_cni_version != "latest") ? var.vpc_cni_version : null
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}

resource "aws_eks_addon" "ebs_csi" {
  count                       = local.enabled && var.enable_ebs_csi ? 1 : 0
  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = (var.ebs_csi_version != null && var.ebs_csi_version != "" && var.ebs_csi_version != "latest") ? var.ebs_csi_version : null
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}

resource "aws_eks_addon" "efs_csi" {
  count                       = local.enabled && var.enable_efs_csi ? 1 : 0
  cluster_name                = var.cluster_name
  addon_name                  = "aws-efs-csi-driver"
  addon_version               = (var.efs_csi_version != null && var.efs_csi_version != "" && var.efs_csi_version != "latest") ? var.efs_csi_version : null
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}
