# CloudWatch Logs module

Creates CloudWatch log groups for EKS control plane logs.

## Usage

```hcl
module "cloudwatch_logs" {
  source            = "./modules/cloudwatch_logs"
  create            = true
  cluster_name      = "example"
  retention_in_days = 90
}
```

## Inputs

- **create**: bool (default: true)
- **cluster_name**: string
- **retention_in_days**: number (default: 90)
- **prevent_destroy**: bool (default: false)
- **tags**: map(string) (default: {})

## Outputs

This module does not export outputs.
