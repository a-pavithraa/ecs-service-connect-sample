variable "region" {
  description = "The AWS region to deploy resources."
  default     = "us-east-1"

}
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.16.0.0/16"
}
variable "domain_name" {
  type = string
}
variable "prefix" {
  type    = string
  default = "techbuzz"

}
variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type    = string
  default = "postgres"
}

variable "db_name" {
  type    = string
  default = "postgres"
}
variable "db_port" {
  type    = number
  default = 5432
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "mailhog_port_smtp" {
  type    = number
  default = 1025
}

variable "mailhog_port_http" {
  type    = number
  default = 8025
}

variable "app_image" {
  type    = string
  default = "sivaprasadreddy/techbuzz"
}
variable "postgres_image" {
  type    = string
  default = "postgres:15.4-alpine"
}
variable "mailhog_image" {
  type    = string
  default = "mailhog/mailhog"
}
variable "db_host" {
  type    = string
  default = "techbuzz-storage"
}
variable "mail_host" {
  type    = string
  default = "techbuzz-email"
}

variable "mail_port" {
  type    = number
  default = 1025
}




