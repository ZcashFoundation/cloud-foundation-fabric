module "ecosystem_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-prod-services"
  location    = "us"
  name          = "ecosystem-services"
  description = "Docker repository storing our ecosystem services"
  format     = { docker = { standard = {} } }
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

resource "google_compute_region_network_endpoint_group" "uptime-kuma-v1" {
  project  = "zfnd-prod-services"
  region = "us-east1"
  name        = "kuma-us-east1"
  description = "Kuma serverless NEG for v1 in us-east1"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service  = "uptime-kuma-v1"
    tag      = null
  }
}

module "kuma_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-prod-services"
  location    = "us"
  name          = "uptime-kuma"
  description = "Docker repository storing our infrastructure monitoring tool"
  format = { docker = { standard = {} } }
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

module "kuma_db_bucket" {
  source     = "../../../../modules/gcs"
  project_id = "zfnd-prod-services"
  prefix     = var.prefix
  name       = "zfnd-kuma-db-backups"
  location   = "US"
  versioning = true
}

module "monitoring-db" {
  source     = "../../../../modules/cloudsql-instance"
  project_id = "zfnd-prod-services"
  network_config = {
    connectivity = {
      psa_config = {
        private_network = var.vpc_self_links.prod-spoke-0
      }
    }
  }
  name             = "monitoring-db"
  region           = "us-east1"
  database_version = "MYSQL_8_0"
  tier             = "db-f1-micro"

  databases = [
    "monitoring"
  ]

  users = {
    # generatea password for user1
    kuma = {
      host     = "%" # allow connection from any host
    }
  }
  gcp_deletion_protection       = false
  terraform_deletion_protection = false
}

module "kuma-db-secret" {
  source     = "../../../../modules/secret-manager"
  project_id = "zfnd-prod-services"
  secrets = {
    UPTIME_KUMA_DB_PASSWORD = {
      locations = ["us-east1"]
    }
  }
}

module "addresses" {
  source     = "../../../../modules/net-address"
  project_id = "zfnd-prod-services"
  global_addresses = {
    "glb-prod-services" = {}
  }
}

module "glb-prod-services-redirect" {
  source     = "../../../../modules/net-lb-app-ext"
  project_id = "zfnd-prod-services"
  name       = "glb-prod-services-redirect"
  address = (
    module.addresses.global_addresses["glb-prod-services"].address
  )
  health_check_configs = {}
  urlmap_config = {
    description = "URL redirect for glb-prod-services."
    default_url_redirect = {
      https         = true
      response_code = "MOVED_PERMANENTLY_DEFAULT"
    }
  }
}

module "glb-prod-services" {
  source     = "../../../../modules/net-lb-app-ext"
  project_id = "zfnd-prod-services"
  name       = "glb-prod-services"
  use_classic_version = false
  address = (
    module.addresses.global_addresses["glb-prod-services"].address
  )
  backend_service_configs = {
    default = {
      backends = [
        { backend = "kuma-us-east1-v1" }
      ]
      health_checks = []
      protocol = "HTTP"
    }
  }
  # with a single serverless NEG the implied default health check is not needed
  health_check_configs = {}
  neg_configs = {
    kuma-us-east1-v1 = {
      cloudrun = {
        region = "us-east1"
        target_service = {
          name = "uptime-kuma-v1"
        }
      }
    }
  }
  protocol = "HTTPS"
  ssl_certificates = {
    managed_configs = {
      kuma-status = {
        domains = ["status.zfnd.org"]
      }
    }
  }
}
