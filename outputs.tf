# Contrato de remote state consumido pelo tc-oficina-infra-db
# (fase-3/infra-k8s.tfstate). Alterar nomes aqui quebra aquele repositório.
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.api.repository_url
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "ecr_repository_urls" {
  description = "URL do repositório ECR de cada microsserviço"
  value       = { for servico, repo in aws_ecr_repository.servicos : servico => repo.repository_url }
}

output "mensageria_topicos_eventos_arn" {
  description = "ARN do tópico SNS de eventos por ambiente (contrato oficial: SSM)"
  value       = { for ambiente, topico in aws_sns_topic.eventos : ambiente => topico.arn }
}

output "mensageria_filas_url" {
  description = "URL de cada fila SQS de trabalho, chave <ambiente>-<fila> (contrato oficial: SSM)"
  value       = { for chave, fila in aws_sqs_queue.fila : chave => fila.url }
}
