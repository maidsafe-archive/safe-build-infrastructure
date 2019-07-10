terraform {
  backend "s3" {
    bucket = "safe-terraform-state"
    key = "staging.tfstate"
    region = "eu-west-2"
  }
}
