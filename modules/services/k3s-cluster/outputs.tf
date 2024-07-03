# output "kubeconfig_file" {
#   value       = local.kubeconfig_external
#   description = "Kubeconfig file content with external IP address"
#   sensitive   = true
# }

# output "kubeconfig" {
#   value       = local.kubeconfig_external
#   description = "Kubeconfig file content with external IP address"
#   sensitive   = true
# }

# output "kubeconfig_data" {
#   description = "Structured kubeconfig data to supply to other providers"
#   value       = local.kubeconfig_data
#   sensitive   = true
# }

output "ip" {
  value = data.http.ip.response_body
}