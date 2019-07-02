terraform {
  backend "s3" {
    bucket = "safe-terraform-state"
    key = "common.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "${var.region}"
}

data "aws_iam_user" "jenkins_build_artifacts" {
  user_name = "${var.jenkins_build_artifacts_username}"
}

resource "aws_s3_bucket" "jenkins_build_artifacts" {
  bucket = "${var.jenkins_build_artifacts_bucket_name}"
  acl = "public-read"
}

resource "aws_iam_user_policy" "jenkins_build_artifacts" {
    name = "jenkins_build_artifacts_user_policy"
    user = "${data.aws_iam_user.jenkins_build_artifacts.user_name}"
    policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.jenkins_build_artifacts.bucket}",
                "arn:aws:s3:::${aws_s3_bucket.jenkins_build_artifacts.bucket}/*"
            ]
        }
   ]
}
EOF
}
