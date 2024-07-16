/**
 * Copyright 2024 Google LLC
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

variable "factories_config" {
  description = "Path to folder with YAML resource description data files."
  type = object({
    hierarchy = optional(object({
      folders_data_path = string
      parent_ids        = optional(map(string), {})
    }))
    projects_data_path = string
    budgets = optional(object({
      billing_account       = string
      budgets_data_path     = string
      notification_channels = optional(map(any), {})
    }))
  })
  nullable = false
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
    dev-spoke-0 = string
  })
}
