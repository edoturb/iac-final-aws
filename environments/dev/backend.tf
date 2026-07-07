# IMPORTANTE: reemplaza el bucket y la tabla por los que crees en el Paso 2
# de las instrucciones (deben existir ANTES de correr `terraform init`).
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "TU-NOMBRE-tfstate-iac-final"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
