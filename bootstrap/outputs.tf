output "talosconfig" {
  description = "Talos client configuration"
  value       = data.talos_client_configuration.talosconfig.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes kubeconfig"
  value       = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive   = true
}

output "cluster_name" {
  description = "Name of the Talos cluster"
  value       = var.cluster_name
}

output "node_endpoints" {
  description = "All node endpoints (all nodes are control plane and schedulable)"
  value       = var.nodes[*].endpoint
}

output "node_ips" {
  description = "All node IPs"
  value       = var.nodes[*].node_ip
}

