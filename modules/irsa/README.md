# IRSA module

Creates an IAM OIDC provider for EKS clusters (IRSA) or uses an existing one.

## Usage

```hcl
module "irsa" {
  source                  = "./modules/irsa"
  create                  = true
  cluster_oidc_issuer_url = module.cluster.cluster_oidc_issuer_url
}
```

## Inputs

- **create**: bool (default: false)
- **cluster_oidc_issuer_url**: string
- **existing_oidc_provider_arn**: string (default: null)
- **tags**: map(string) (default: {})

## Outputs

- **oidc_provider_arn**: OIDC provider ARN
