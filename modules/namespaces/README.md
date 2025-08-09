# Namespaces module

Creates Kubernetes namespaces with optional labels.

## Usage

```hcl
module "namespaces" {
  source     = "./modules/namespaces"
  create     = true
  namespaces = [
    { name = "default" },
    { name = "observability", labels = { "app.kubernetes.io/part-of" = "obs" } }
  ]
}
```

## Inputs

- **create**: bool (default: false)
- **namespaces**: list(object({ name = string, labels = optional(map(string), {}) }))

## Outputs

This module does not export outputs.
