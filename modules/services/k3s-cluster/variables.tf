variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API token"
}

variable "env" {
  description = "The name to use for all the cluster resources"
  type        = string
  nullable = false
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
  nullable = false
}

variable "cluster_server_os" {
  description = "The OS to use for the cluster servers"
  type        = string
  default     = "ubuntu-24.04"
}

variable "cluster_master_node_type" {
  description = "The server type to use for the master node"
  type        = string
  default     = "cax11"
}

variable "cluster_location" {
  description = "The location to use for the cluster"
  type        = string
  default     = "hel1"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.cluster_location))
    error_message = "The cluster location must be lowercase."
  }
}

variable "cluster_worker_node_count" {
  description = "The number of worker nodes to create"
  type        = number
  default     = 1
  validation {
    condition     = var.cluster_worker_node_count >= 0
    error_message = "The number of worker nodes must be greater than or equal to 0."
  }
}

variable "cluster_worker_node_type" {
  description = "The server type to use for the worker nodes"
  type        = string
  default     = "cax11"
}

variable "ssh_port" {
  description = "The main SSH port to connect to the nodes."
  type        = number
  default     = 22

  validation {
    condition     = var.ssh_port >= 0 && var.ssh_port <= 65535
    error_message = "The SSH port must use a valid range from 0 to 65535."
  }
}

variable "ssh_user" {
  description = "The SSH user to connect to the nodes."
  type        = string
  default     = "root"
}

variable "firewall_ids" {
  description = "List of firewall IDs to attach to the nodes."
  type        = list(string)
  default     = []
}

variable "cluster_private_network_name" {
  description = "The name to use for the private network."
  type        = string
  default     = "kubernetes-cluster"
}

variable "cluster_private_network_ip_range" {
  description = "The IP range to use for the private network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_private_network_subnet_ip_range" {
  description = "The IP range to use for the private network."
  type        = string
  default     = "10.0.1.0/24"
}

variable "cluster_private_network_subnet_zone" {
  description = "The IP range to use for the private network."
  type        = string
  default     = "eu-central"
}

variable "cluster_master_node_private_ip" {
  description = "The private IP address of the master node."
  type        = string
  default     = "10.0.1.1"
}

variable "k3s_file_path" {
  description = "The path to the k3s.yaml file."
  type        = string
  default     = "/etc/rancher/k3s/k3s.yaml"
}

variable "generated_ssh_key_name" {
  type        = string
  default     = "terraform-key-pair"
  description = "Key-pair generated by Terraform"
}

variable "ssh_key_algorithm" {
  description = "The SSH key algorithm to use."
  type        = string
  default     = "RSA"
}

variable "cluster_firewall_name" {
  description = "The name to use for the firewall."
  type        = string
  default     = "k3s-firewall"
}

# variable "cluster_firewall_rules" {
#   description = "The rules to use for the firewall."
#   type = list(object({
#     description     = string
#     direction       = string
#     protocol        = string
#     port            = string
#     source_ips      = list(string)
#     destination_ips = list(string)
#   }))
#   default = [
#     {
#       description = "SSH: Allow all incoming traffic on port 22"
#       direction   = "in"
#       protocol    = "tcp"
#       port        = "22"
#       source_ips = [
#         "0.0.0.0/0",
#         "::/0"
#       ]
#     },
#     {
#       description = "HTTPS: Allow all incoming traffic on port 443"
#       direction   = "in"
#       protocol    = "tcp"
#       port        = "443"
#       source_ips = [
#         "0.0.0.0/0"
#       ]
#     },
#     {
#       description = "HTTPS: Allow all incoming traffic on port 443"
#       direction   = "out"
#       protocol    = "tcp"
#       port        = "443"
#       destination_ips = [
#         "0.0.0.0/0", "::/0"
#       ]
#     },
#     {
#       description = "HTTP: Allow all incoming traffic on port 80"
#       direction   = "out"
#       protocol    = "tcp"
#       port        = "80"
#       destination_ips = [
#         "0.0.0.0/0", "::/0"
#       ]
#     },
#     {
#       description = "K3s: Allow all incoming traffic on port 2379-2380"
#       direction   = "in"
#       protocol    = "tcp"
#       port        = "2379-2380"
#       source_ips = [
#         "0.0.0.0/0",
#         "::/0"
#       ]
#     },
#     {
#       description = "K3s: Allow all incoming traffic on port 6443"
#       direction   = "in"
#       protocol    = "tcp"
#       port        = "6443"
#       source_ips = [
#         "0.0.0.0/0",
#         "::/0"
#       ]
#     },
#     {
#       description = "ICMP: Allow all incoming traffic"
#       direction   = "in"
#       protocol    = "icmp"
#       source_ips = [
#         "0.0.0.0/0",
#         "::/0"
#       ]
#     }
#   ]
# }

variable "cluster_nginx_ingress_version" {
  description = "The version of the nginx ingress controller to install."
  type        = string
  default     = "4.10.1"
  
}