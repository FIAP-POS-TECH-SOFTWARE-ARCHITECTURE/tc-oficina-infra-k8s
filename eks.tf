resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  role_arn = data.aws_iam_role.lab_role.arn

  vpc_config {
    subnet_ids = aws_subnet.public[*].id
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

# Os pods usam a credencial da LabRole pelo IMDS do node. Com IMDSv2 e hop
# limit 1 (padrão do node group), a resposta não atravessa o salto da rede do
# pod e o SDK falha com "Could not load credentials from any providers".
resource "aws_launch_template" "nodes" {
  name_prefix = "${var.project_name}-nodes-"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name           = aws_eks_cluster.main.name
  node_group_name_prefix = "${var.project_name}-nodes-"
  node_role_arn          = data.aws_iam_role.lab_role.arn
  subnet_ids             = aws_subnet.public[*].id
  instance_types         = [var.eks_instance_type]

  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  scaling_config {
    desired_size = var.eks_desired_size
    min_size     = var.eks_min_size
    max_size     = var.eks_max_size
  }

  update_config {
    max_unavailable = 1
  }

  # Troca de launch template recria o node group: o novo sobe antes de o
  # antigo sair, e os pods migram sem o cluster ficar sem nodes.
  lifecycle {
    create_before_destroy = true
  }

  # Os nodes só entram no cluster com saída para a internet. Sem esta
  # dependência, o apply com -target do CD (etapa 1) cria o node group antes
  # do internet gateway e das rotas, e ele fica preso em CREATING.
  depends_on = [aws_route_table_association.public]
}
