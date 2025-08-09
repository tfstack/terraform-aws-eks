locals {
  enabled = var.create
}

resource "aws_cloudwatch_log_group" "control_plane" {
  count             = local.enabled && (var.prevent_destroy == false) ? 1 : 0
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.retention_in_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_cloudwatch_log_group" "control_plane_protected" {
  count             = local.enabled && var.prevent_destroy ? 1 : 0
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.retention_in_days
  tags              = var.tags

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name]
  }
}
