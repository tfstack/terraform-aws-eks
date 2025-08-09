#########################################
# AWS Account & Region Data
#########################################

data "aws_caller_identity" "current" {}

#########################################
# Local Values
#########################################

locals {
  enabled          = var.create
  effective_sg_ids = var.create_security_group && local.enabled ? [aws_security_group.cluster[0].id] : coalesce(var.security_group_ids, [])

  # Limit usage of data.aws_caller_identity to outputs and not to decide resource count
  caller_arn = data.aws_caller_identity.current.arn
  account_id = data.aws_caller_identity.current.account_id
  is_assumed = can(regex(":assumed-role/", local.caller_arn))
  is_role    = can(regex(":role/", local.caller_arn))
  is_user    = can(regex(":user/", local.caller_arn))

  # Extract role name if assumed-role; STS ARN form: ...:assumed-role/<ROLE_NAME>/<SESSION>
  assumed_role_name = local.is_assumed ? element(split("/", local.caller_arn), 1) : null
  derived_principal_arn = local.is_assumed ? "arn:aws:iam::${local.account_id}:role/${local.assumed_role_name}" : (
    (local.is_role || local.is_user) ? local.caller_arn : null
  )

  # Compute executor role but avoid using it in count directly
  effective_executor_role_arn = try(coalesce(var.executor_role_arn, local.derived_principal_arn), null)
}

resource "aws_iam_role" "cluster" {
  count = local.enabled ? 1 : 0

  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cluster_policies" {
  for_each   = local.enabled ? toset(["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]) : toset([])
  role       = aws_iam_role.cluster[0].name
  policy_arn = each.value
}

resource "aws_security_group" "cluster" {
  count = local.enabled && var.create_security_group ? 1 : 0

  name        = "${var.cluster_name}-cluster-sg"
  description = "Cluster security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.cluster_name}-cluster-sg" })
}

resource "aws_eks_cluster" "this" {
  count = local.enabled ? 1 : 0

  name     = var.cluster_name
  role_arn = aws_iam_role.cluster[0].arn
  version  = var.cluster_version

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = false
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = local.effective_sg_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  dynamic "encryption_config" {
    for_each = var.kms_key_arn == null ? [] : [var.kms_key_arn]
    content {
      provider {
        key_arn = encryption_config.value
      }
      resources = ["secrets"]
    }
  }

  dynamic "kubernetes_network_config" {
    for_each = var.service_cidr == null ? [] : [var.service_cidr]
    content {
      service_ipv4_cidr = kubernetes_network_config.value
    }
  }

  dynamic "upgrade_policy" {
    for_each = try(var.upgrade_policy.support_type, null) == null ? [] : [var.upgrade_policy]
    content {
      support_type = try(upgrade_policy.value.support_type, null)
    }
  }

  dynamic "zonal_shift_config" {
    for_each = try(var.zonal_shift_config.enabled, false) ? [var.zonal_shift_config] : []
    content {
      enabled = try(zonal_shift_config.value.enabled, false)
    }
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  dynamic "timeouts" {
    for_each = [1]
    content {
      create = try(var.timeouts.create, null)
      update = try(var.timeouts.update, null)
      delete = try(var.timeouts.delete, null)
    }
  }

  tags = var.tags
}

#########################################
# EKS Access Entry for Terraform Executor
#########################################

## Wait for cluster visibility to EKS Access API (eventual consistency)
resource "time_sleep" "wait_for_cluster_visibility" {
  count = local.enabled ? 1 : 0

  depends_on      = [aws_eks_cluster.this]
  create_duration = "30s"
}

resource "aws_eks_access_entry" "terraform_executor" {
  count         = local.enabled ? 1 : 0
  cluster_name  = var.cluster_name
  principal_arn = local.effective_executor_role_arn

  depends_on = [time_sleep.wait_for_cluster_visibility]

  lifecycle {
    precondition {
      condition     = local.effective_executor_role_arn != null
      error_message = "executor_role_arn or a determinable caller principal is required to create Terraform executor access entry."
    }
  }
}

resource "aws_eks_access_policy_association" "terraform_executor" {
  count         = local.enabled ? 1 : 0
  cluster_name  = var.cluster_name
  principal_arn = local.effective_executor_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [time_sleep.wait_for_cluster_visibility]

  lifecycle {
    precondition {
      condition     = local.effective_executor_role_arn != null
      error_message = "executor_role_arn or a determinable caller principal is required to create access policy association."
    }
  }
}

# Give EKS a moment to propagate access entries before callers use the API
resource "time_sleep" "wait_for_access_propagation" {
  count = local.enabled ? 1 : 0

  depends_on      = [aws_eks_access_policy_association.terraform_executor]
  create_duration = "20s"
}

#######################################
# Auth for cluster access
#######################################

data "aws_eks_cluster_auth" "this" {
  count      = local.enabled ? 1 : 0
  name       = var.cluster_name
  depends_on = [aws_eks_cluster.this]
}
