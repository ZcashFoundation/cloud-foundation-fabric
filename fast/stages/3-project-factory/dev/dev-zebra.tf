module "zebra_caching_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-dev-zebra"
  location    = "us"
  name          = "zebra"
  description = "Docker repository storing the Zebra application for testing purposes"
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

module "zebra_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-dev-zebra"
  location    = "us"
  name          = "zebra-caching"
  description = "Docker repository storing Zebra's build layers for caching"
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

module "lwd_caching_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-dev-zebra"
  location    = "us"
  name          = "lightwalletd"
  description = "Docker repository storing the Zebra application for testing purposes"
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

module "lwd_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-dev-zebra"
  location    = "us"
  name          = "lightwalletd-caching"
  description = "Docker repository storing Zebra's build layers for caching"
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

resource "google_compute_health_check" "http-health-check" {
  name        = "zebrad-tracing-filter"
  description = "Health check via http"
  project     = "zfnd-dev-zebra"

  timeout_sec         = 10
  check_interval_sec  = 30
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port               = "3000"
    port_specification = "USE_FIXED_PORT"
    request_path       = "/filter"
    proxy_header       = "NONE"
    # TODO: we should validate a specific response, not ANY response
    # response           = "I AM HEALTHY"
  }
}
