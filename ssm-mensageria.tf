# Contrato com os CDs dos microsserviços: ARNs/URLs publicados no SSM.
# Nenhum outro repositório lê o state deste — só estes parâmetros.
resource "aws_ssm_parameter" "mensageria_topico_eventos" {
  for_each = toset(var.environments)

  name  = "/${var.project_name}/${each.key}/mensageria/eventos-topic-arn"
  type  = "String"
  value = aws_sns_topic.eventos[each.key].arn
}

resource "aws_ssm_parameter" "mensageria_fila_url" {
  for_each = local.filas

  name  = "/${var.project_name}/${each.value.ambiente}/mensageria/${each.value.fila}-url"
  type  = "String"
  value = aws_sqs_queue.fila[each.key].url
}

resource "aws_ssm_parameter" "mensageria_dlq_url" {
  for_each = local.filas

  name  = "/${var.project_name}/${each.value.ambiente}/mensageria/${each.value.fila}-dlq-url"
  type  = "String"
  value = aws_sqs_queue.dlq[each.key].url
}
