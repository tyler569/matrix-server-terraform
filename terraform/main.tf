terraform {
  backend "s3" {
    bucket = "philbrick-terraform-state-backend"
    key = "terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "terraform_state_lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.254.254.0/24"
}
