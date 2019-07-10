terraform {
  backend "s3" {
    bucket = "safe-terraform-state"
    key = "dev.tfstate"
    region = "eu-west-2"
  }
}
