terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-west-2"
}

variable "create_instance" {
  default = false  # Set to false to destroy the instance after creation
}

resource "aws_instance" "Atlantis_Testserver" {
  ami           = "ami-0b2e759b077980407"
  instance_type = "t2.micro"

  tags = {
    Name = "AtlantisServerInstance"
  }
}
