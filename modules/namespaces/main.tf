locals {
  enabled = var.create && length(var.namespaces) > 0
}

resource "kubernetes_namespace" "this" {
  for_each = local.enabled ? { for ns in var.namespaces : ns.name => ns } : {}

  metadata {
    name   = each.key
    labels = try(each.value.labels, {})
  }
}
