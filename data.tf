data "aws_iam_role" "lab_role" {
  name = "LabRole" # role pré-existente do AWS Academy, não é possível criar roles
}

data "aws_availability_zones" "available" {
  state = "available"
}
