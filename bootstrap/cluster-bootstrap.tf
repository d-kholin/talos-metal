# Apply configuration to all control plane nodes
resource "talos_machine_configuration_apply" "cp_config_apply" {
  count = length(var.nodes)

  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  node                        = var.nodes[count.index].endpoint

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = var.install_disk
          image = var.talos_image
        }
        kubelet = {
          extraMounts = [
            {
              destination = "/var/lib/longhorn"
              type        = "bind"
              source      = "/var/lib/longhorn"
              options     = ["bind", "rshared", "rw"]
            }
          ]
        }
        network = {
          hostname = var.nodes[count.index].name
        }
      }
    }),

    yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = true
      }
    }),
  ]
}

# Bootstrap etcd on the first control plane node
resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.cp_config_apply]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.nodes[0].endpoint
}

# Check cluster health (optional - may fail if nodes haven't fully registered in Kubernetes yet)
# The health check verifies that all control plane nodes are healthy, Kubernetes API is available,
# and all nodes are registered. This can take several minutes after bootstrap.
data "talos_cluster_health" "health" {
  count       = var.wait_for_cluster_health ? 1 : 0
  depends_on  = [talos_machine_bootstrap.bootstrap]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  control_plane_nodes  = [for node in var.nodes : node.endpoint]
  endpoints            = [for node in var.nodes : node.endpoint]
}

# Generate kubeconfig
# Note: kubeconfig can be generated after bootstrap, even if cluster health check is still pending
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.nodes[0].endpoint
}

# Save kubeconfig to file
resource "local_file" "kubeconfig" {
  depends_on    = [talos_cluster_kubeconfig.kubeconfig]
  content       = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename      = "${path.module}/kubeconfig"
  file_permission = "0600"
}

