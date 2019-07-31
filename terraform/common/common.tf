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

data "aws_iam_user" "jenkins_deploy_artifacts" {
  user_name = "${var.jenkins_deploy_artifacts_username}"
}

resource "aws_s3_bucket" "safe_cli_deploy" {
  bucket = "${var.safe_cli_deploy_bucket_name}"
  acl = "public-read"
}

resource "aws_s3_bucket" "safe_vault_deploy" {
  bucket = "${var.safe_vault_deploy_bucket_name}"
  acl = "public-read"
}

resource "aws_iam_user_policy" "jenkins_deploy_artifacts" {
    name = "jenkins_deploy_artifacts_user_policy"
    user = "${data.aws_iam_user.jenkins_deploy_artifacts.user_name}"
    policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.safe_cli_deploy.bucket}",
                "arn:aws:s3:::${aws_s3_bucket.safe_cli_deploy.bucket}/*"
                "arn:aws:s3:::${aws_s3_bucket.safe_vault_deploy.bucket}",
                "arn:aws:s3:::${aws_s3_bucket.safe_vault_deploy.bucket}/*"
            ]
        }
   ]
}
EOF
}

data "aws_iam_user" "packer" {
  user_name = "${var.packer_username}"
}

# This user policy was taken from here:
# https://www.packer.io/docs/builders/amazon.html#using-an-iam-instance-profile
resource "aws_iam_user_policy" "packer" {
    name = "packer_user_policy"
    user = "${data.aws_iam_user.packer.user_name}"
    policy= <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
      "Effect": "Allow",
      "Action" : [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource" : "*"
  }]
}
EOF
}
