variable "region" {
  default = "eu-west-2"
  description = "The AWS region to use"
}

variable "jenkins_build_artifacts_username" {
  default = "jenkins-build_artifacts"
  description = "Username of the IAM user for uploading build artifacts to S3."
}

variable "jenkins_build_artifacts_bucket_name" {
  default = "safe-jenkins-build-artifacts"
  description = "Name for the bucket that build artifacts are uploaded to."
}

variable "jenkins_deploy_artifacts_username" {
  default = "jenkins-deploy_artifacts"
  description = "Username of the IAM user for uploading deployment artifacts to S3."
}

variable "safe_cli_deploy_bucket_name" {
  default = "safe-cli"
  description = "Name for bucket to deploy safe-cli binaries to."
}

variable "packer_username" {
  default = "packer"
  description = "Username of the IAM user for running Packer to generate AMIs."
}
