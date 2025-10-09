terraform {
  backend "s3" {
  }
  required_version = "~> 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.18.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "~> 1.26.0"
    }
  }
}


