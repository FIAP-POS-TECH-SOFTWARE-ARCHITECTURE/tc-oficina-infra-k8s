locals {
  tags = {
    Project   = "tech-challenge-fiap"
    Phase     = "fase-3"
    ManagedBy = "terraform"
  }
  cluster_name = "${var.project_name}-eks"
}
