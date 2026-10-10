# Repositório da imagem do monolito da fase anterior. Mantido enquanto o
# pipeline do OS e os Deployments ainda usarem a imagem daqui; remover só
# depois que nenhum Deployment referenciar "/oficina-api:".
resource "aws_ecr_repository" "api" {
  name                 = "${var.project_name}-api"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Um repositório por microsserviço (imagens com tag "<ambiente>-<sha>").
resource "aws_ecr_repository" "servicos" {
  for_each = toset(["os-service", "billing-service", "execution-service"])

  name                 = "${var.project_name}-${each.key}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
