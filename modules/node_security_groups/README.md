# Node security groups module

Creates security groups for EKS worker nodes.

## Usage

```hcl
module "node_security_groups" {
  source      = "./modules/node_security_groups"
  create      = true
  vpc_id      = "vpc-xxxxxxxxxxxxxxxxx"
  name_prefix = "eks-nodes"
}
```

## Inputs

- **create**: bool (default: false)
- **vpc_id**: string
- **name_prefix**: string (default: "eks-nodes")
- **tags**: map(string) (default: {})

## Outputs

This module does not export outputs.
