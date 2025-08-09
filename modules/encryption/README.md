# Encryption module

Creates a KMS key for EKS secret encryption (when enabled).

## Usage

```hcl
module "encryption" {
  source     = "./modules/encryption"
  create     = true
  alias_name = "eks/my-cluster"
}
```

## Inputs

- **create**: bool (default: false)
- **alias_name**: string (default: "eks")
- **tags**: map(string) (default: {})

## Outputs

- **kms_key_arn**: KMS key ARN
- **kms_key_id**: KMS key ID
