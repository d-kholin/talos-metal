terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = ">= 0.7.2"
  }  
}
}
provider "kubernetes" {
  config_path = "C:\\Users\\micha\\.kube\\config"
}

provider "helm" {
  kubernetes = {
    config_path = "C:\\Users\\micha\\.kube\\config"
    host        = var.cluster_endpoint
  }
}