data "aws_caller_identity" "current_iam" {}

locals {
  tags = {
    project              = var.project
    service              = var.service
    purpose-environment  = terraform.workspace
    deployer-iam-account = data.aws_caller_identity.current_iam.account_id
  }
}