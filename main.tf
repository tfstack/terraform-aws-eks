locals {
  kms_key_arn_effective = var.encryption_kms_key_arn != null ? var.encryption_kms_key_arn : module.encryption.kms_key_arn

  effective_private_subnet_ids      = coalesce(try(var.cluster_vpc_config.private_subnet_ids, null), var.private_subnet_ids)
  effective_public_access_cidrs     = coalesce(try(var.cluster_vpc_config.public_access_cidrs, null), var.cluster_endpoint_public_access_cidrs)
  effective_private_access_cidrs    = try(var.cluster_vpc_config.private_access_cidrs, null)
  effective_security_group_ids      = try(var.cluster_vpc_config.security_group_ids, null)
  effective_endpoint_private_access = try(var.cluster_vpc_config.endpoint_private_access, null)
  effective_endpoint_public_access  = try(var.cluster_vpc_config.endpoint_public_access, null)
  effective_service_cidr            = try(var.cluster_vpc_config.service_cidr, null)

  # IRSA module should only be called if IRSA is enabled and no existing provider is specified
  enable_irsa_module = (var.enable_irsa || var.enable_oidc) && var.existing_oidc_provider_arn == null
}

# Discover available Kubernetes versions to support "latest"
data "aws_eks_cluster_versions" "available" {}

locals {
  latest_k8s_version    = try(reverse(sort(data.aws_eks_cluster_versions.available.cluster_versions))[0], null)
  effective_k8s_version = var.cluster_version == "latest" ? local.latest_k8s_version : var.cluster_version
}

module "encryption" {
  source = "./modules/encryption"

  create     = var.enable_cluster_encryption && var.encryption_kms_key_arn == null
  alias_name = "eks/${var.cluster_name}"
  tags       = var.tags
}

module "cloudwatch_logs" {
  source = "./modules/cloudwatch_logs"

  create            = var.create && var.enable_cloudwatch_observability
  cluster_name      = var.cluster_name
  retention_in_days = var.eks_log_retention_days
  prevent_destroy   = var.eks_log_prevent_destroy
  tags              = var.tags
}

module "cluster" {
  source = "./modules/cluster"

  create                                = var.create
  cluster_name                          = var.cluster_name
  cluster_version                       = local.effective_k8s_version
  vpc_id                                = var.vpc_id
  private_subnet_ids                    = local.effective_private_subnet_ids
  cluster_endpoint_public_access_cidrs  = local.effective_public_access_cidrs
  cluster_endpoint_private_access_cidrs = local.effective_private_access_cidrs
  endpoint_private_access               = local.effective_endpoint_private_access
  endpoint_public_access                = local.effective_endpoint_public_access
  security_group_ids                    = local.effective_security_group_ids
  create_security_group                 = var.create_security_group
  enabled_cluster_log_types             = var.cluster_enabled_log_types
  service_cidr                          = local.effective_service_cidr
  upgrade_policy                        = var.cluster_upgrade_policy
  zonal_shift_config                    = var.cluster_zonal_shift_config
  timeouts                              = var.timeouts
  kms_key_arn                           = var.enable_cluster_encryption ? local.kms_key_arn_effective : null
  authentication_mode                   = var.cluster_authentication_mode
  executor_role_arn                     = var.cluster_executor_role_arn
  tags                                  = var.tags

  depends_on = [
    module.cloudwatch_logs
  ]
}

module "node_groups" {
  source = "./modules/node_groups"

  create                         = var.create
  cluster_name                   = module.cluster.cluster_name
  cluster_endpoint               = module.cluster.eks_cluster_endpoint
  cluster_ca_certificate         = module.cluster.eks_cluster_ca_cert
  managed_node_groups            = var.managed_node_groups
  self_managed_node_groups       = var.self_managed_node_groups
  node_group_additional_policies = var.node_group_additional_policies
  tags                           = var.tags
}

module "addons" {
  source = "./modules/addons"

  create          = var.create
  cluster_name    = module.cluster.cluster_name
  cluster_version = local.effective_k8s_version

  enable_coredns  = var.enable_coredns
  coredns_version = var.coredns_version

  enable_kube_proxy  = var.enable_kube_proxy
  kube_proxy_version = var.kube_proxy_version

  enable_vpc_cni  = var.enable_vpc_cni
  vpc_cni_version = var.vpc_cni_version

  enable_ebs_csi  = var.enable_ebs_csi
  ebs_csi_version = var.ebs_csi_version

  enable_efs_csi  = var.enable_efs_csi
  efs_csi_version = var.efs_csi_version

  depends_on = [
    module.node_groups
  ]
}

module "access" {
  source = "./modules/access"

  create       = var.create
  cluster_name = module.cluster.cluster_name
  access_entries = { for entry in var.access_entries : entry.principal_arn => {
    principal_arn     = entry.principal_arn
    policy_arn        = entry.policy_arn
    kubernetes_groups = try(entry.kubernetes_groups, [])
    type              = try(entry.type, null)
    access_scope      = try(entry.access_scope, null)
  } }
}

module "namespaces" {
  source = "./modules/namespaces"

  create = var.create && length(var.namespaces) > 0
  namespaces = (
    can(var.namespaces[0])
    ? [
      for ns in var.namespaces : {
        name   = ns.name
        labels = try(ns.labels, {})
      }
    ]
    : [
      for k, v in var.namespaces : {
        name   = k
        labels = try(v.labels, {})
      }
    ]
  )

  depends_on = [
    module.cluster
  ]
}

module "irsa" {
  source = "./modules/irsa"

  create                  = local.enable_irsa_module && var.create
  cluster_oidc_issuer_url = (local.enable_irsa_module && var.create) ? module.cluster.cluster_oidc_issuer_url : null
  tags                    = var.tags
}
