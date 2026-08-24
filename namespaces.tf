# Um namespace por ambiente no mesmo cluster (trade-off Academy: 2 ambientes
# sem pagar 2 clusters). O CD do app (spec 05) faz deploy dentro deles.
resource "kubernetes_namespace" "env" {
  for_each = toset(var.environments)

  metadata {
    name = each.key
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      environment                    = each.key
    }
  }

  depends_on = [aws_eks_node_group.main]
}
