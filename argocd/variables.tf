variable "cluster_endpoint" {
  type = string
}
variable "git_repo" {
  type = string
}

variable "git_rev" {
  type    = string
  default = "main"
}

variable "enable_root_app" {
  type    = bool
  default = true
  description = "Create the Argo CD root Application (requires Application CRD to exist)."
}
variable "cloudflare_api_token" {
  description = "Cloudflare API token for cert-manager DNS01"
  type        = string
  sensitive   = true
}