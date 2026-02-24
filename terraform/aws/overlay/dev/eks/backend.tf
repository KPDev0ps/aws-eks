terraform {
  backend "s3" {
    bucket         = "terraf0rmstate1"
    key            = "default-subnet/terraform.tfstate"
    region         = "eu-west-2"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "true"
    }
  }
}
