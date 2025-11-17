variable "nodes" {
  description = "List of node configurations (all nodes are control plane and schedulable)"
  type = list(object({
    name     = string
    endpoint = string
    node_ip  = string
  }))
  default = [
    {
      name     = "node1"
      endpoint = "192.168.1.10"
      node_ip  = "192.168.1.10"
    },
    {
      name     = "node2"
      endpoint = "192.168.1.11"
      node_ip  = "192.168.1.11"
    },
    {
      name     = "node3"
      endpoint = "192.168.1.12"
      node_ip  = "192.168.1.12"
    }
  ]
}

variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "talos-cluster"
}

variable "cluster_endpoint" {
  description = "Kubernetes API server endpoint (use first node IP or load balancer)"
  type        = string
  default     = "https://192.168.1.10:6443"
}

variable "talos_version" {
  description = "Talos OS version"
  type        = string
  default     = "v1.7.0"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.30.0"
}

variable "install_disk" {
  description = "Disk to install Talos on"
  type        = string
  default     = "/dev/sda"
}

variable "talos_image" {
  description = "Talos image"
  type        = string
  default     = "factory.talos.dev/metal-installer/613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245:v1.11.5"
}

variable "wait_for_cluster_health" {
  description = "Wait for cluster health check to pass before completing (may fail if nodes haven't fully registered in Kubernetes yet)"
  type        = bool
  default     = false
}

