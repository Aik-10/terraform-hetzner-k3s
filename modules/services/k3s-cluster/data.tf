data "hcloud_ssh_keys" "all_keys" {}

data "cloudinit_config" "master-config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloudinit.yaml.tftpl", {
      ssh_authorized_key = tls_private_key.master_key.public_key_openssh
    })
  }
}

data "cloudinit_config" "worker-config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/worker-cloudinit.yaml.tftpl", {
      ssh_authorized_key = tls_private_key.master_key.public_key_openssh
      ssh_private_key = tls_private_key.master_key.private_key_openssh
      master_private_ip = var.cluster_master_node_private_ip
    })
  }
}