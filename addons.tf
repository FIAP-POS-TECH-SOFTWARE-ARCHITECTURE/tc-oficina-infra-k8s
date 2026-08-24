# metrics-server: requisito do HPA (na Fase 2 era instalado manualmente).
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.2"

  depends_on = [aws_eks_node_group.main]
}

# Bundle New Relic: métricas de cluster (CPU/memória), eventos e envio de
# logs dos pods (Fluent Bit) — base dos dashboards do spec 06.
# Sem license key o recurso não é criado (ver variables.tf); a versão do chart
# fica flutuante por recomendação da New Relic para o nri-bundle.
resource "helm_release" "newrelic" {
  count = var.new_relic_license_key == "" ? 0 : 1

  name             = "newrelic-bundle"
  repository       = "https://helm-charts.newrelic.com"
  chart            = "nri-bundle"
  namespace        = "newrelic"
  create_namespace = true

  set {
    name  = "global.licenseKey"
    value = var.new_relic_license_key
  }
  set {
    name  = "global.cluster"
    value = aws_eks_cluster.main.name
  }
  set {
    name  = "newrelic-infrastructure.privileged"
    value = "true"
  }
  set {
    name  = "kube-state-metrics.enabled"
    value = "true"
  }
  set {
    name  = "newrelic-logging.enabled"
    value = "true"
  }
  set {
    name  = "newrelic-logging.lowDataMode"
    value = "false"
  }

  depends_on = [aws_eks_node_group.main]
}
