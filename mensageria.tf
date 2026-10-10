# Mensageria da orquestração da ordem de serviço (por ambiente):
# - comandos: uma fila SQS por serviço consumidor (execution, billing);
# - eventos: um tópico SNS único com fan-out; a fila do orquestrador (OS)
#   assina o tópico recebendo só eventos de billing e execution.
# Toda fila tem DLQ: 5 recebimentos sem sucesso movem a mensagem para a DLQ.
locals {
  filas_mensageria = ["execucao-comandos", "billing-comandos", "os-orquestrador-eventos"]

  # Chave "<ambiente>-<fila>", ex.: "homolog-execucao-comandos"
  filas = {
    for par in setproduct(var.environments, local.filas_mensageria) :
    "${par[0]}-${par[1]}" => { ambiente = par[0], fila = par[1] }
  }
}

resource "aws_sns_topic" "eventos" {
  for_each = toset(var.environments)

  name = "${var.project_name}-${each.key}-eventos"
}

resource "aws_sqs_queue" "dlq" {
  for_each = local.filas

  name                       = "${var.project_name}-${each.value.ambiente}-${each.value.fila}-dlq"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 1209600 # 14 dias: tempo para analisar e reprocessar
  receive_wait_time_seconds  = 20
}

resource "aws_sqs_queue" "fila" {
  for_each = local.filas

  name                       = "${var.project_name}-${each.value.ambiente}-${each.value.fila}"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600 # 4 dias
  receive_wait_time_seconds  = 20     # long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = 5
  })
}

# Recurso separado (e não atributo da DLQ) para evitar ciclo:
# a fila referencia a DLQ no redrive e a DLQ referencia a fila aqui.
resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  for_each = local.filas

  queue_url = aws_sqs_queue.dlq[each.key].id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.fila[each.key].arn]
  })
}
