terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}
data "aws_availability_zones" "available" {}
data "aws_route53_zone" "this" {
  name = var.domain_name
}
data "aws_caller_identity" "current" {}
locals {
  zone_id = data.aws_route53_zone.this.zone_id
  common_tags = {
    app     = "${var.prefix}_ecs"
    version = "V1"
  }
}