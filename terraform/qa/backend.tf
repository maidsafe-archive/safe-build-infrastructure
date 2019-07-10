terraform {
  backend "s3" {
    bucket = "safe-terraform-state"
    key = "qa.tfstate"
    region = "eu-west-2"
  }
}
