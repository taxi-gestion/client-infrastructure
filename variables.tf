variable "terraform_organization" {
  type        = string
  description = "The organization name on terraform cloud"
  nullable    = false
}

variable "tfe_token" {
  description = "TFE Team token"
  nullable    = false
  default     = false
  sensitive   = true
}

variable "project" {
  type        = string
  nullable    = false
  description = "The name of the project that hosts the environment"
}

variable "service" {
  type        = string
  nullable    = false
  description = "The name of the service that will be run on the environment"
}

variable "domain_name" {
  type        = string
  nullable    = true
  description = "The project registered domain name that cloudfront can use as aliases, for now only one domain is supported"
  default     = ""
}

variable "hosting_zone_name" {
  type        = string
  nullable    = true
  description = "The name of the route53 hosting zone"
  default     = ""
}

variable "hosting_zone_id" {
  type        = string
  nullable    = true
  description = "The id of the route53 hosting zone"
  default     = ""
}

variable "api_endpoint" {
  type        = string
  nullable    = false
  description = "The project api endpoint origin that get forwarded to an api gateway, for now only one endpoint is supported"
}

variable "acm_certificate_arn" {
  type        = string
  nullable    = true
  description = "The project certificate ARN for your domain. Leave empty to use the cloudfront certificate (need to use the cloudfront domain too)"
  default     = ""
}

# TODO This is ugly an should be reworked
variable "content_security_policy_client" {
  type        = string
  nullable    = false
  description = "The name of the service that will be run on the environment"
  default     = "default-src 'self' data: https://cognito-idp.us-east-1.amazonaws.com ; font-src 'self'; img-src 'self'; object-src 'none'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; trusted-types angular angular#bundler dompurify; require-trusted-types-for 'script';"
}