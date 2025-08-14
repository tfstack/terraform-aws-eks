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

# Key policy to allow EKS to use this key
resource "aws_kms_key_policy" "eks" {
  count  = local.enabled ? 1 : 0
  key_id = aws_kms_key.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EKS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ]
        Resource = "*"
      }
    ]
  })
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
