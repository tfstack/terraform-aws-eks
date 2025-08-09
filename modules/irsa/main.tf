locals {
  # Only depend on inputs known at plan time for count determinism
  enabled = var.create && var.existing_oidc_provider_arn == null
}

# Create OIDC provider only if enabled
resource "aws_iam_openid_connect_provider" "this" {
  count          = local.enabled ? 1 : 0
  url            = var.cluster_oidc_issuer_url
  client_id_list = ["sts.amazonaws.com"]
  # Note: thumbprint_list is optional, will be auto-populated by AWS
  tags = var.tags
}
