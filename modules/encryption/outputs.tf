output "kms_key_arn" {
  description = "KMS key ARN"
  value       = try(aws_kms_key.this[0].arn, null)
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = try(aws_kms_key.this[0].key_id, null)
}
