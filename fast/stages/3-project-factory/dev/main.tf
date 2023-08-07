/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# tfdoc:file:description Project factory.

module "projects" {
  source = "../../../../modules/project-factory"
  data_defaults = {
    billing_account = var.billing_account.id
    # more defaults are available, check the project factory variables
  }
  data_merges = {
    labels = {
      environment = "dev"
    }
    services = [
      "stackdriver.googleapis.com"
    ]
  }
  data_overrides = {
    prefix = "${var.prefix}-dev"
  }
  factories_config = var.factories_config
}

module "zebra_caching_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-dev-zebra"
  location    = "us"
  format      = "DOCKER"
  id          = "zebra"
  description = "Docker repository storing the Zebra application for testing purposes"
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

module "zebra_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-dev-zebra"
  location    = "us"
  format      = "DOCKER"
  id          = "zebra-caching"
  description = "Docker repository storing Zebra's build layers for caching"
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

module "lwd_caching_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-dev-zebra"
  location    = "us"
  format      = "DOCKER"
  id          = "lightwalletd"
  description = "Docker repository storing the Zebra application for testing purposes"
  iam = {
    "roles/artifactregistry.reader" = ["allUsers"]
  }
}

module "lwd_artifact_registry" {
  source      = "../../../../modules/artifact-registry"
  project_id  = "zfnd-dev-zebra"
  location    = "us"
  format      = "DOCKER"
  id          = "lightwalletd-caching"
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

module "runner-mig-dind" {
  source         = "github.com/terraform-google-modules/terraform-google-github-actions-runners?ref=v3.1.1//modules/gh-runner-mig-container-vm"
  create_network = true
  subnetwork_project = var.subnetwork_project
  subnet_name    = var.subnet_name
  subnet_ip     = var.subnet_ip
  service_account = null
  project_id     = var.project_id
  image          = var.image
  repo_name      = var.repo_name
  repo_url       = var.repo_url
  repo_owner     = var.repo_owner
  gh_token       = var.gh_token
  region         = var.region
  dind           = true
}
