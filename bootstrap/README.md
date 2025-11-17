# Talos OS Cluster Bootstrap with Terraform

This directory contains Terraform configuration to bootstrap a Talos OS cluster on 3 physical machines. All nodes are configured as control plane nodes and are made schedulable (can run workloads).

## Prerequisites

1. **Talos Installer**: Each physical machine should have booted the Talos installer and be accessible via `talosctl`
2. **Terraform**: Install Terraform >= 1.0
3. **talosctl**: Install `talosctl` CLI tool
4. **kubectl**: Install `kubectl` for cluster management
5. **Shell Environment** (Windows): The Terraform configuration uses shell commands. On Windows, you'll need:
   - WSL (Windows Subsystem for Linux), or
   - Git Bash, or
   - Run Terraform from a Linux/Mac environment

## Setup

1. **Copy the example variables file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your actual machine IPs and configuration:
   ```hcl
   nodes = [
     {
       name     = "node1"
       endpoint = "YOUR_NODE1_IP"
       node_ip  = "YOUR_NODE1_IP"
     },
     {
       name     = "node2"
       endpoint = "YOUR_NODE2_IP"
       node_ip  = "YOUR_NODE2_IP"
     },
     {
       name     = "node3"
       endpoint = "YOUR_NODE3_IP"
       node_ip  = "YOUR_NODE3_IP"
     }
   ]

   cluster_name     = "talos-cluster"
   cluster_endpoint = "https://YOUR_NODE1_IP:6443"
   install_disk     = "/dev/sda"  # Adjust based on your disk
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Review the plan**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## What This Does

1. **Generates Talos machine configurations** for:
   - 3 control plane nodes (all nodes are control plane)

2. **Applies configurations** to each machine via `talosctl apply-config`

3. **Bootstraps etcd** on the first node

4. **Generates kubeconfig** for cluster access

5. **Waits for all nodes to join** the cluster

6. **Removes taints** from control plane nodes to make them schedulable (allows workloads to run on them)

## Post-Deployment

After successful deployment:

1. **Use the generated kubeconfig**:
   ```bash
   export KUBECONFIG=./kubeconfig
   kubectl get nodes
   ```

2. **Verify cluster status and that nodes are schedulable**:
   ```bash
   kubectl get nodes -o wide
   kubectl describe nodes | grep -i taint
   kubectl get pods -A
   ```
   
   All nodes should show no taints (or only the `node-role.kubernetes.io/control-plane` label without the NoSchedule taint), meaning they can schedule workloads.

## Troubleshooting

- **Connection issues**: Ensure machines are accessible and `talosctl` can connect
- **Bootstrap fails**: Check that the first node is fully booted and accessible
- **Nodes not joining**: Verify network connectivity and that configurations were applied correctly
- **Nodes not schedulable**: If nodes still have taints after deployment, manually remove them:
  ```bash
  kubectl taint nodes <node-name> node-role.kubernetes.io/control-plane:NoSchedule-
  ```

## Manual Steps (if needed)

If Terraform fails at any step, you can manually:

1. Apply config to a node:
   ```bash
   talosctl apply-config --insecure --nodes <NODE_IP> --file <config.yaml>
   ```

2. Bootstrap etcd:
   ```bash
   talosctl bootstrap --nodes <CP1_IP> --insecure
   ```

3. Get kubeconfig:
   ```bash
   talosctl kubeconfig --nodes <CP1_IP> --insecure
   ```

## Notes

- **All nodes are control plane**: All 3 nodes are configured as control plane nodes and are made schedulable
- **Schedulable control plane**: The configuration automatically removes the taint that prevents scheduling on control plane nodes
- The configuration uses `--insecure` flag for initial setup. For production, configure proper TLS certificates.
- Adjust `install_disk` based on your hardware (e.g., `/dev/nvme0n1` for NVMe drives)
- The cluster endpoint should point to your first node IP or a load balancer

