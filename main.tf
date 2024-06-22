# Tell Terraform to include the hcloud provider
terraform {
  required_version = ">= 0.13"  
}

module "main_cluster" {
  source = "./modules/services/k3s-cluster"
  
  env = "production"
  cluster_name = "lentokone-k3s-test"
  hcloud_token = var.hcloud_token
}