terraform {
  backend "s3" {
    bucket       = "tc-fiap-oficina-tfstate-076155200589"
    key          = "fase-3/infra-k8s.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
