provider "hcloud" {
  token = var.hcloud_token
}

terraform {
  required_version = ">= 0.13"
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">= 0.1.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
  }
}

resource "tls_private_key" "master_key" {
  algorithm = var.ssh_key_algorithm
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "master_node_key" {
  name       = var.generated_ssh_key_name
  public_key = tls_private_key.master_key.public_key_openssh
  depends_on = [tls_private_key.master_key]
}

resource "hcloud_network" "private_network" {
  name     = var.cluster_private_network_name
  ip_range = var.cluster_private_network_ip_range
}

resource "hcloud_network_subnet" "private_network_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.private_network.id
  network_zone = var.cluster_private_network_subnet_zone
  ip_range     = var.cluster_private_network_subnet_ip_range
}

resource "hcloud_firewall" "basic_firewall" {
  name = var.cluster_firewall_name
  labels = {
    cluster = var.cluster_name
    environment     = var.environment
  }
}

resource "hcloud_server" "master-node" {
  name        = "${var.cluster_name}-master"
  image       = var.cluster_server_os
  server_type = var.cluster_master_node_type
  location    = var.cluster_location

  ssh_keys = concat([hcloud_ssh_key.master_node_key.name], data.hcloud_ssh_keys.all_keys.ssh_keys.*.name)

  labels = {
    environment  = var.environment
    node = "master"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  lifecycle {
    ignore_changes = [
      location,
      ssh_keys,
      user_data,
      image,
    ]
  }

  network {
    network_id = hcloud_network.private_network.id
    # IP Used by the master node, needs to be static
    # Here the worker nodes will use "var.master_node_private_ip" to communicate with the master node
    ip = var.cluster_master_node_private_ip
  }

  user_data = data.cloudinit_config.master-config.rendered
  # If we don't specify this, Terraform will create the resources in parallel
  # We want this node to be created after the private network is created
  depends_on   = [hcloud_network_subnet.private_network_subnet, hcloud_ssh_key.master_node_key]
  /* TODO: Implement firewall and make that config to right */
  # firewall_ids = concat([hcloud_firewall.basic_firewall.id], var.firewall_ids)
}

resource "hcloud_server" "worker-nodes" {
  count = var.cluster_worker_node_count

  name        = "${var.cluster_name}-worker-${count.index}"
  image       = var.cluster_server_os
  server_type = var.cluster_worker_node_type
  location    = var.cluster_location

  labels = {
    environment  = var.environment
    node = "worker"
  }

  ssh_keys = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name
  shutdown_before_deletion = true

  lifecycle {
    ignore_changes = [
      location,
      ssh_keys,
      user_data,
      image,
    ]
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.private_network.id
  }

  user_data    = data.cloudinit_config.worker-config.rendered
  depends_on   = [hcloud_network_subnet.private_network_subnet, hcloud_server.master-node]
  firewall_ids = concat([hcloud_firewall.basic_firewall.id], var.firewall_ids)
}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [hcloud_server.master-node, hcloud_server.worker-nodes]
  create_duration = "60s"
}

data "remote_file" "kubeconfig" {
  conn {
    host        = hcloud_server.master-node.ipv4_address
    port        = var.ssh_port
    user        = var.ssh_user
    private_key = tls_private_key.master_key.private_key_openssh
  }

  path = var.k3s_file_path

  depends_on = [time_sleep.wait_60_seconds]
}

locals {
  kubeconfig_server_address = hcloud_server.master-node.ipv4_address
  kubeconfig_external       = replace(data.remote_file.kubeconfig.content, "127.0.0.1", local.kubeconfig_server_address)
  kubeconfig_parsed         = yamldecode(local.kubeconfig_external)
  kubeconfig_data = {
    host                   = local.kubeconfig_parsed["clusters"][0]["cluster"]["server"]
    client_certificate     = base64decode(local.kubeconfig_parsed["users"][0]["user"]["client-certificate-data"])
    client_key             = base64decode(local.kubeconfig_parsed["users"][0]["user"]["client-key-data"])
    cluster_ca_certificate = base64decode(local.kubeconfig_parsed["clusters"][0]["cluster"]["certificate-authority-data"])
  }
}

resource "local_sensitive_file" "kubeconfig" {
  content         = local.kubeconfig_external
  filename        = "kubeconfig.yaml"
  file_permission = "600"
}


provider "helm" {
  kubernetes {
    host                   = local.kubeconfig_data.host
    client_certificate     = local.kubeconfig_data.client_certificate
    client_key             = local.kubeconfig_data.client_key
    cluster_ca_certificate = local.kubeconfig_data.cluster_ca_certificate
  }
}

