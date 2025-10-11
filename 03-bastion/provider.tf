# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "6.0.0"
  
#     }
    
#   }
#   backend "s3" {
#     bucket         = "msvs-remote-state"
#     key            = "expense-infra-dev-bastion"
#     region         = "us-east-1"
#     dynamodb_table = "msvs-dynamo"
#   }
# }

# provider "aws" {
#     region = "us-east-1"
#   # Configuration options
# }

    
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0.0"
  
    }
    
  }
  backend "s3" {
    bucket         = "devopswithmsvs"
    key            = "expense-infra-dev-astt"
    region         = "us-east-1"
    #dynamodb_table = "msvs-dynamo"
    use_lockfile  = true
  }
}

provider "aws" {
    region = "us-east-1"
  # Configuration options
}

    