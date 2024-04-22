terraform {
  backend "s3" {
    bucket            = "Atlantis-terraform-state-files-playground"
    key               = "atlantis-ec2.tfstate"
    region            = "eu-west-2"
    encrypt           = true
    dynamodb_table    = "terraform_state_atlantis"
  }
}

module "dev" {
  source = "./modules"
  providers = {
    aws = aws.dev
  }
}

provider "aws" {
    alias   = "dev"
    region  = "eu-west-2"
    
}