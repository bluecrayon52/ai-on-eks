resource "kubectl_manifest" "ai_ml_observability_yaml" {
  count     = var.enable_ai_ml_observability_stack ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/ai-ml-observability.yaml")

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "aibrix_dependency_yaml" {
  count     = var.enable_aibrix_stack ? 1 : 0
  yaml_body = templatefile("${path.module}/argocd-addons/aibrix-dependency.yaml", { aibrix_version = var.aibrix_stack_version })

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "aibrix_core_yaml" {
  count     = var.enable_aibrix_stack ? 1 : 0
  yaml_body = templatefile("${path.module}/argocd-addons/aibrix-core.yaml", { aibrix_version = var.aibrix_stack_version })

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "nvidia_nim_yaml" {
  count     = var.enable_nvidia_nim_stack ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/nvidia-nim-operator.yaml")

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "nvidia_dcgm_helm" {
  yaml_body = templatefile("${path.module}/argocd-addons/nvidia-dcgm-helm.yaml", { service_monitor_enabled = var.enable_ai_ml_observability_stack })

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "cert_manager_yaml" {
  count     = var.enable_cert_manager ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/cert-manager.yaml")

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubernetes_secret" "argocd_bitnami_repo" {
  count     = var.enable_slurm_cluster ? 1 : 0
  metadata {
    name      = "argocd-bitnami-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    type      = "helm"
    name      = "bitnami"
    enableOCI = "true"
    url       = "registry-1.docker.io/bitnamicharts"
  }
  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubernetes_secret" "argocd_metrics_server_repo" {
  count     = var.enable_slurm_cluster ? 1 : 0
  metadata {
    name      = "argocd-metrics-server-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    type      = "helm"
    name      = "metrics-server"
    enableOCI = "false"
    url       = "https://kubernetes-sigs.github.io/metrics-server/"
  }
  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "slurm_operator_yaml" {
  count     = var.enable_slurm_operator ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/slinky-slurm/slurm-operator.yaml")

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "slurm_cluster_yaml" {
  count     = var.enable_slurm_cluster ? 1 : 0
  yaml_body = templatefile("${path.module}/argocd-addons/slinky-slurm/slurm-cluster.yaml", {
    slurm_values = indent(8, templatefile("${path.module}/argocd-addons/slinky-slurm/slurm-values.yaml", {
      image_repository = var.image_repository
      image_tag = var.image_tag
      ssh_key = var.ssh_key
    }))
  })

  depends_on = [
    module.eks_blueprints_addons,
    kubectl_manifest.slurm_operator_yaml,
    kubectl_manifest.priority_class,
    kubernetes_secret.argocd_bitnami_repo,
    kubernetes_secret.argocd_metrics_server_repo,
  ]
}