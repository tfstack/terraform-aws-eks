# Access module

Manages EKS access entries and policy associations for principals.

## Usage

```hcl
module "access" {
  source       = "./modules/access"
  create       = true
  cluster_name = module.cluster.cluster_name

  access_entries = {
    "arn:aws:iam::123456789012:user/admin" = {
      policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    }
  }
}
```

## Inputs

- **create**: bool (default: true)
- **cluster_name**: string
- **access_entries**: map(object({
  - policy_arn: string
  - principal_arn: optional(string)
  - kubernetes_groups: optional(list(string), [])
  - type: optional(string)
  - access_scope: optional(object({ type = string, namespaces = optional(list(string), []) }), null)
}))

## Outputs

This module does not export outputs.
