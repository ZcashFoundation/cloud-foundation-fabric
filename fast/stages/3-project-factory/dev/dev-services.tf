module "ecosystem_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-dev-services"
  location    = "us"
  name          = "ecosystem-services"
  description = "Docker repository storing our ecosystem services"
  format     = { docker = { standard = {} } }
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

module "kuma_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-dev-services"
  location    = "us"
  name          = "uptime-kuma"
  description = "Docker repository storing our infrastructure monitoring tool"
  format     = { docker = { standard = {} } }
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

module "kuma_db_bucket" {
  source     = "../../../../modules/gcs"
  project_id = "zfnd-dev-services"
  prefix     = var.prefix
  name       = "uptime-kuma"
  location   = "US"
  versioning = true
}
module "monitoring-db" {
  source     = "../../../../modules/cloudsql-instance"
  project_id = "zfnd-dev-services"
  network_config = {
    connectivity = {
      psa_config = {
        private_network = var.vpc_self_links.dev-spoke-0
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
  project_id = "zfnd-dev-services"
  secrets = {
    UPTIME_KUMA_DB_PASSWORD = {
      locations = ["us-east1"]
    }
  }
}
