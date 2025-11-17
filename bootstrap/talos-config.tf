# Generate machine secrets
resource "talos_machine_secrets" "machine_secrets" {}

# Generate client configuration (talosconfig)
data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [for node in var.nodes : node.endpoint]
}

# Generate Talos machine configuration for control plane nodes
data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

# Save talosconfig to file
resource "local_file" "talosconfig" {
  content         = data.talos_client_configuration.talosconfig.talos_config
  filename        = "${path.module}/talosconfig"
  file_permission = "0600"
}

