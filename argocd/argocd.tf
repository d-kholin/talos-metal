resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
}

resource "helm_release" "argocd" {
  name            = "argocd"
  namespace       = kubernetes_namespace.argocd.metadata[0].name
  atomic          = true
  cleanup_on_fail = true
  skip_crds       = false
  repository      = "https://argoproj.github.io/argo-helm"
  chart           = "argo-cd"
  version         = "9.1.3"
  values = [
    yamlencode({
      server = {
        service = { type = "ClusterIP" }
      }
      configs = {
        params = {
          "server.insecure" = "true"
        }
      }
    })
  ]
}

# Seed app of apps
resource "kubernetes_manifest" "root_app" {
  count      = var.enable_root_app ? 1 : 0
  depends_on = [helm_release.argocd]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "cluster-bootstrap"
      namespace = "argocd"
      annotations = {
        "argocd.argoproj.io/sync-wave" = "-10"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.git_repo
        targetRevision = var.git_rev
        path           = "infra/apps"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated   = { prune = true, selfHeal = true }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
}
