# terraform {
#   backend "s3" {
#     bucket         = "my-tf-state-bucket"
#     key            = "env/${terraform.workspace}/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#   }
# }
