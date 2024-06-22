# This Terraform configuration file sets up a Kubernetes cluster using Hetzner Cloud.
# It includes the hcloud provider and uses a module to create the cluster.

terraform {
  required_version = ">= 0.13"  
}

module "main_cluster" {
  source = "./modules/services/k3s-cluster"
  
  # The environment variable specifies the environment in which the cluster is being deployed.
  environment = "production"
  
  # The cluster_name variable specifies the name of the Kubernetes cluster.
  cluster_name = "k3s-test"
  
  # The hcloud_token variable is used to authenticate with the Hetzner Cloud API.
  hcloud_token = var.hcloud_token
}