module "acm" {

  source            = "terraform-aws-modules/acm/aws"
  version           = "4.4.0"
  domain_name       = var.domain_name
  zone_id           = local.zone_id
  validation_method = "DNS"
  subject_alternative_names = [
    "*.${var.domain_name}"
  ]
}
