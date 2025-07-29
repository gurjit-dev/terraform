terraform {
  cloud {
    organization = "gurjit-singh"

    workspaces {
      project = "Learn Terraform"
      name    = "aws"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}
