variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefixo dos recursos"
  type        = string
  default     = "oficina"
}

variable "eks_instance_type" {
  description = "Tipo de instância do node group"
  type        = string
  default     = "t3.medium"
}

variable "eks_desired_size" {
  type    = number
  default = 2
}

variable "eks_min_size" {
  type    = number
  default = 2
}

variable "eks_max_size" {
  type    = number
  default = 4
}

# Mesma lista usada pelo tc-oficina-infra-db (bancos lógicos) — manter em sincronia.
variable "environments" {
  type    = list(string)
  default = ["homolog", "prod"]
}
