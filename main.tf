# This Terraform configuration file sets up a Kubernetes cluster using Hetzner Cloud.
# It includes the hcloud provider and uses a module to create the cluster.

terraform {
  required_version = ">= 0.13"  
}

locals {
  cluster_name = "k3s-test"
  environment = "production"
}

module "main_cluster" {
  source = "./modules/services/k3s-cluster"
  
  # The environment variable specifies the environment in which the cluster is being deployed.
  environment = local.environment
  
  # The cluster_name variable specifies the name of the Kubernetes cluster.
  cluster_name = local.cluster_name
  
  # The hcloud_token variable is used to authenticate with the Hetzner Cloud API.
  hcloud_token = var.hcloud_token

  cluster_worker_node_count = 1

  labels = {
    cluster     = local.cluster_name
    environment = local.environment
  }
}