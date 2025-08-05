terraform {
  backend "s3" {
    bucket         = "gsingh-terraform-state-bucket"
    key            = "eks/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}