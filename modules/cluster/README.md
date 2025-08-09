# Cluster module

Creates and configures an Amazon EKS cluster.

## Usage

```hcl
module "cluster" {
  source = "./modules/cluster"

  create             = true
  cluster_name       = "example"
  cluster_version    = "1.31"
  vpc_id             = "vpc-xxxxxxxxxxxxxxxxx"
  private_subnet_ids = ["subnet-aaaa", "subnet-bbbb", "subnet-cccc"]
}
```

## Inputs

- **create**: bool (default: true)
- **cluster_name**: string
- **cluster_version**: string
- **vpc_id**: string
- **private_subnet_ids**: list(string)
- **security_group_ids**: list(string) (default: null)
- **create_security_group**: bool (default: true)
- **cluster_endpoint_public_access_cidrs**: list(string) (default: ["0.0.0.0/0"])
- **cluster_endpoint_private_access_cidrs**: list(string) (default: [])
- **endpoint_private_access**: bool (default: false)
- **endpoint_public_access**: bool (default: true)
- **enabled_cluster_log_types**: list(string) (default: [])
- **service_cidr**: string (default: null)
- **upgrade_policy**: object({ support_type = optional(string) }) (default: {})
- **zonal_shift_config**: object({ enabled = optional(bool) }) (default: {})
- **timeouts**: object({ create = optional(string), update = optional(string), delete = optional(string) }) (default: {})
- **kms_key_arn**: string (default: null)
- **authentication_mode**: string (default: "API_AND_CONFIG_MAP")
- **executor_role_arn**: string (default: null)
- **tags**: map(string) (default: {})

## Outputs

- **cluster_name**: Cluster name
- **cluster_arn**: Cluster ARN
- **cluster_oidc_issuer_url**: OIDC issuer URL
- **eks_cluster_endpoint**: Cluster endpoint
- **eks_cluster_ca_cert**: Base64-decoded cluster CA cert
- **eks_cluster_auth_token**: Authentication token (sensitive)
