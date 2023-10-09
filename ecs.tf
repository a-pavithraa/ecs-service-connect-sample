resource "aws_service_discovery_http_namespace" "example" {
  name        = var.prefix
  description = "Namespace for ${var.prefix} ECS services"
}
module "ecs" {
  source     = "terraform-aws-modules/ecs/aws"
  depends_on = [aws_service_discovery_http_namespace.example]

  cluster_name = "${var.prefix}_cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {
    techbuzz-storage = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {

        techbuzz-storage = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = var.postgres_image
          environment = [{
            name  = "POSTGRES_USER"
            value = var.db_username
            }, {
            name  = "POSTGRES_PASSWORD"
            value = var.db_password
            }, {
            name  = "POSTGRES_DB"
            value = var.db_name
          }]

          port_mappings = [
            {
              name          = var.db_host
              containerPort = var.db_port
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem  = false
          enable_cloudwatch_logging = true

          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.example.http_name
        service = {
          client_alias = {
            port     = var.db_port
            dns_name = var.db_host
          }
          port_name      = var.db_host
          discovery_name = var.db_host
        }
      }

      subnet_ids = module.vpc.private_subnets
      security_group_rules = {
        db-security-group = {
          type        = "ingress"
          from_port   = var.db_port
          to_port     = var.db_port
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
          # source_security_group_id = "sg-12345678"
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    techbuzz-email = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {

        techbuzz-email = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "mailhog/mailhog"


          port_mappings = [
            {
              name          = var.mail_host
              containerPort = var.mailhog_port_smtp
              protocol      = "tcp"
            },
            {
              name          = "${var.mail_host}-external"
              containerPort = var.mailhog_port_http
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem  = false
          enable_cloudwatch_logging = true

          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.example.http_name
        service = {
          client_alias = {
            port     = var.mailhog_port_smtp
            dns_name = var.mail_host
          }
          port_name      = var.mail_host
          discovery_name = var.mail_host
        }
      }
      load_balancer = {
        service = {
          target_group_arn = element(module.alb.target_group_arns, 1)
          container_name   = var.mail_host
          container_port   = 8025
        }
      }

      subnet_ids = module.vpc.private_subnets
      security_group_rules = {
        email-security-group = {
          type        = "ingress"
          from_port   = var.mailhog_port_smtp
          to_port     = var.mailhog_port_smtp
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
          # source_security_group_id = "sg-12345678"
        }
        email-security-group-external = {
          type        = "ingress"
          from_port   = var.mailhog_port_http
          to_port     = var.mailhog_port_http
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
          # source_security_group_id = "sg-12345678"
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }

    }
    techbuzz-main-app = {
      cpu    = 1024
      memory = 4096


      # Container definition(s)
      container_definitions = {

        techbuzz-main-app = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "pavithravasudevan/techbuzz"
          environment = [
            {
              "name" : "spring.datasource.url",
              "value" : "jdbc:postgresql://${var.db_host}:${var.db_port}/${var.db_name}?user=${var.db_username}&password=${var.db_password}&useSSL=false"
            },
            {
              "name" : "SPRING_PROFILES_ACTIVE",
              "value" : "docker"
            },
            {
              "name" : "server.ssl.enabled",
              "value" : "false"
            },
            {
              "name" : "MAIL_HOST",
              "value" : var.mail_host

              }, {
              "name" : "MAIL_PORT",
              "value" : var.mailhog_port_smtp

          }]

          port_mappings = [
            {
              name          = "techbuzz-main-app"
              containerPort = var.app_port
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem  = false
          enable_cloudwatch_logging = true

          memory_reservation = 100
        }
      }
      load_balancer = {
        service = {
          target_group_arn = element(module.alb.target_group_arns, 0)
          container_name   = "techbuzz-main-app"
          container_port   = var.app_port
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.example.http_name

      }

      subnet_ids = module.vpc.private_subnets
      security_group_rules = {
        app-security-group = {
          type        = "ingress"
          from_port   = var.app_port
          to_port     = var.app_port
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
          # source_security_group_id = "sg-12345678"
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = local.common_tags
}