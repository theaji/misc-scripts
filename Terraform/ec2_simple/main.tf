terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }

  }

}

provider "aws" {
  region  = "us-east-1"

}

resource "aws_instance" "testing_server" {
  ami           = "ami-0fe472d8a85bc7b0e"
  instance_type = "t2.micro"

  tags = {
    Name = "tf-server"
  }
}
