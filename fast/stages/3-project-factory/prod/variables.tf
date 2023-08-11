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

#TODO: tfdoc annotations

variable "billing_account" {
  # tfdoc:variable:source 0-bootstrap
  description = "Billing account id. If billing account is not part of the same org set `is_org_level` to false."
  type = object({
    id           = string
    is_org_level = optional(bool, true)
  })
  validation {
    condition     = var.billing_account.is_org_level != null
    error_message = "Invalid `null` value for `billing_account.is_org_level`."
  }
}

variable "data_dir" {
  description = "Relative path for the folder storing configuration data."
  type        = string
  default     = "data/projects"
}

variable "defaults_file" {
  description = "Relative path for the file storing the project factory configuration."
  type        = string
  default     = "data/defaults.yaml"
}

variable "environment_dns_zone" {
  # tfdoc:variable:source 2-networking
  description = "DNS zone suffix for environment."
  type        = string
  default     = null
}

variable "host_project_ids" {
  # tfdoc:variable:source 2-networking
  description = "Host project for the shared VPC."
  type = object({
    prod-spoke-0 = string
  })
  default = null
}

variable "prefix" {
  # tfdoc:variable:source 0-bootstrap
  description = "Prefix used for resources that need unique names. Use 9 characters or less."
  type        = string

  validation {
    condition     = try(length(var.prefix), 0) < 10
    error_message = "Use a maximum of 9 characters for prefix."
  }
}

variable "vpc_self_links" {
  # tfdoc:variable:source 2-networking
  description = "Self link for the shared VPC."
  type = object({
    prod-spoke-0 = string
  })
  default = null
}

# self-hosted runners variables

variable "project_id" {
  type        = string
  description = "The project id to deploy Github Runner MIG"
}

variable "image" {
  type        = string
  description = "The github runner image"
}

variable "repo_url" {
  type        = string
  description = "Repo URL for the Github Action"
}


variable "repo_name" {
  type        = string
  description = "Name of the repo for the Github Action"
}


variable "repo_owner" {
  type        = string
  description = "Owner of the repo for the Github Action"
}

variable "gh_token" {
  type        = string
  description = "Github token that is used for generating Self Hosted Runner Token"
}

variable "region" {
  type        = string
  description = "The GCP region to deploy instances into"
  default     = "us-east1"
}

variable "subnetwork_project" {
  type        = string
  description = "The ID of the project in which the subnetwork belongs. If it is not provided, the project_id is used."
  default     = ""
}

variable "subnet_name" {
  type        = string
  description = "Name for the subnet"
  default     = ""
}

variable "subnet_ip" {
  type        = string
  description = "IP range for the subnet"
  default     = ""
}

variable "service_account" {
  description = "Service account email address"
  type        = string
  default     = ""
}