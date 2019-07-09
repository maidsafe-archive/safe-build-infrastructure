terraform {
  backend "s3" {
    bucket = "safe-terraform-state"
    key = "prod.tfstate"
    region = "eu-west-2"
  }
}
