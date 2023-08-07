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

output "projects" {
  description = "Created projects."
  value = {
    for k, v in module.projects.projects : k => {
      number     = v.number
      project_id = v.id
    }
  }
}

output "service_accounts" {
  description = "Created service accounts."
  value       = module.projects.service_accounts
}

# self-hosted runners outputs

output "mig_instance_group" {
  description = "The instance group url of the created MIG"
  value       = module.runner-mig-dind.mig_instance_group
}

output "mig_name" {
  description = "The name of the MIG"
  value       = module.runner-mig-dind.mig_name
}
