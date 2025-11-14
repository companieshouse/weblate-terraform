terraform {
  backend "s3" {
  }
  required_version = "~> 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.17"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.25.0, < 5.3.1"
    }
    # postgresql = {
    #   source  = "cyrilgdn/postgresql"
    #   version = "~> 1.26.0"
    # }
  }
}


