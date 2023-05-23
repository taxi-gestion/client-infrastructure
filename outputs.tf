locals {
  export_as_organization_variable = {
    "cloudfront_s3_bucket" = {
      hcl       = false
      sensitive = false
      value     = aws_s3_bucket.client.bucket
    }
    "cloudfront_distribution_id" = {
      hcl       = false
      sensitive = false
      value     = aws_cloudfront_distribution.distribution.id
    }
  }
}

data "tfe_organization" "organization" {
  name = var.terraform_organization
}

data "tfe_variable_set" "variables" {
  name         = "variables"
  organization = data.tfe_organization.organization.name
}

resource "tfe_variable" "output_values" {
  for_each = local.export_as_organization_variable

  key             = each.key
  value           = each.value.hcl ? jsonencode(each.value.value) : tostring(each.value.value)
  category        = "terraform"
  description     = "${each.key} variable from the ${var.service} service"
  variable_set_id = data.tfe_variable_set.variables.id
  hcl             = each.value.hcl
  sensitive       = each.value.sensitive
}
