locals {
  enabled = var.create && length(var.access_entries) > 0
}

resource "aws_eks_access_entry" "this" {
  for_each      = local.enabled ? var.access_entries : {}
  cluster_name  = var.cluster_name
  principal_arn = try(each.value.principal_arn, each.key)
  type          = try(each.value.type, null)

  kubernetes_groups = try(each.value.kubernetes_groups, null)
}

resource "aws_eks_access_policy_association" "this" {
  for_each      = local.enabled ? var.access_entries : {}
  cluster_name  = var.cluster_name
  principal_arn = try(each.value.principal_arn, each.key)
  policy_arn    = each.value.policy_arn

  dynamic "access_scope" {
    for_each = [true]
    content {
      type       = try(each.value.access_scope.type, "cluster")
      namespaces = try(each.value.access_scope.namespaces, null)
    }
  }
}
