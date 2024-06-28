provider "helm" {
  kubernetes {
    host                   = module.gke-multitenant.clusters.cluster-0.endpoint
    token                  = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(module.gke-multitenant.clusters.cluster-0.ca_certificate)
  }
}

provider "kubernetes" {
  host                   = "https://${module.gke-multitenant.clusters.cluster-0.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(module.gke-multitenant.clusters.cluster-0.ca_certificate)
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.12.0"
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    module.gke-multitenant.clusters
  ]
}

resource "kubernetes_secret" "github_token" {
  metadata {
    name      = "github-token"
    namespace = "arc-runners"
  }
  data = {
    github_token = var.github_token
  }
}

resource "helm_release" "actions-runner-controller" {
  name             = "actions-runner-controller"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts/"
  chart            = "gha-runner-scale-set-controller"
  version          = "0.6.1"
  namespace        = "arc-systems"
  create_namespace = true
  cleanup_on_fail  = true
  wait             = true
  wait_for_jobs    = true

  depends_on = [
    helm_release.cert-manager
  ]
}

resource "helm_release" "zfnd-runner-set" {
  name             = "zfnd-runners"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts/"
  chart            = "gha-runner-scale-set"
  version          = "0.6.1"
  namespace        = "arc-runners"
  create_namespace = true
  cleanup_on_fail  = true
  wait             = true
  wait_for_jobs    = true
  # values = [templatefile("${path.module}/kubernetes/values-arc-set.yaml.tpl", {
  #   github-org-url       = "https://github.com/ZcashFoundation",
  #   github-config-secret = kubernetes_secret.github_token.metadata[0].name
  #   github-runner-name = "zfnd-runners"
  # })]

  set {
    name  = "runnerScaleSetName"
    value = "zfnd-runners"
  }

  set {
    name  = "githubConfigUrl"
    value = "https://github.com/ZcashFoundation"
  }

  set {
    name  = "githubConfigSecret.github_token"
    value = var.github_token
  }

  depends_on = [
    helm_release.actions-runner-controller
  ]
}
