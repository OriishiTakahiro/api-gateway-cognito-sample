terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.53.0"
    }
    archive = {
      version = "~>2.3.0"
    }
  }
}

locals {
  region = "ap-northeast-1"
}

provider "aws" {
  region = local.region
}

provider "archive" {
}

