# Terraform Hetzner Cloud K3s Cluster
This project contains Terraform scripts to deploy a K3s (Lightweight Kubernetes) cluster on Hetzner Cloud.

## Prerequisites
Before you begin, ensure you have met the following requirements:

- [Terraform](https://www.terraform.io/) installed
- A Hetzner Cloud account
- SSH key for accessing the nodes
- Hetzner Cloud API token
- Add Hetzner cloud token to environment variable.

    ```bash
    export TF_VAR_hcloud_token=$token
    ```

## Setup Instructions
Coming later

## Clean Up
To destroy the infrastructure, run:

```bash
terraform destroy
```