# Basic example

End-to-end example that provisions a VPC and an EKS cluster with common addons, namespaces, and node groups.

## Prerequisites

- Terraform >= 1.3 (see module `versions.tf`)
- AWS credentials configured with sufficient permissions

## Usage

Navigate to this directory and apply:

```bash
terraform init
terraform apply -auto-approve
```

The example:

- Creates a VPC (via `cloudbuildlab/vpc/aws`)
- Creates an EKS cluster using the root module in this repository
- Enables cluster encryption with KMS (automatically creates and configures KMS key)
- Enables CoreDNS, kube-proxy, VPC CNI, EBS CSI, EFS CSI
- Creates two node groups (general and spot)
- Creates example namespaces `monitoring` and `logging`

## Important variables (set in `main.tf`)

- Region: `ap-southeast-2`
- Cluster version: `latest` (resolved dynamically)
- VPC CIDR: `10.0.0.0/16`
- Private subnets: `10.0.101.0/24`, `10.0.102.0/24`, `10.0.103.0/24`
- Public subnets: `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`

## Outputs

After apply, you can use the following from the root module outputs (exposed in this example via `module.eks`):

- `module.eks.cluster_name`
- `module.eks.cluster_endpoint`
- `module.eks.cluster_ca_certificate`
- `module.eks.cluster_auth_token` (sensitive)

These are wired to the `kubernetes` and `helm` providers in the example for immediate use.

## Cleanup

```bash
terraform destroy -auto-approve
```
