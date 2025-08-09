locals {
  enabled = var.create
}

resource "aws_kms_key" "this" {
  count                   = local.enabled ? 1 : 0
  description             = "EKS secret encryption key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags                    = var.tags
}

resource "aws_kms_alias" "this" {
  count         = local.enabled ? 1 : 0
  name          = "alias/${var.alias_name}"
  target_key_id = aws_kms_key.this[0].key_id
}
