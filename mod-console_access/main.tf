/**
 * Copyright 2025 Google LLC
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
 
# Provider Configuration
provider "google" {
  project = var.provider_project_id
  region  = var.region
}

# CORRECTED: Use a 'data' source to look up the existing Access Policy
# for your organization instead of trying to create a new one.
data "google_access_context_manager_access_policy" "access_policy" {
  parent = "organizations/${var.organization_id}"
}

# Access Level specifying who can access and from where
resource "google_access_context_manager_access_level" "console_access" {
  # This now correctly references the 'name' attribute of the data source
  parent = "accessPolicies/${data.google_access_context_manager_access_policy.access_policy.name}"
  name   = "accessPolicies/${data.google_access_context_manager_access_policy.access_policy.name}/accessLevels/console_users"
  title  = "Access for Console Users from Corporate IPs"
  basic {
    combining_function = "AND"
    conditions {
      ip_subnetworks = [
        "203.0.113.0/24",
        "2620:0:1045:1f:20c4:f846:12fe:3c69/128"
      ]
    }
    conditions {
      members = [
        "user:gadmin@maorhz.altostrat.com",
        #        "group:your-gcp-admins@example.com",
      ]
    }
  }
}

# Service Perimeter with Ingress Policy for the Console
resource "google_access_context_manager_service_perimeter" "my_perimeter" {
  parent = "accessPolicies/${data.google_access_context_manager_access_policy.access_policy.name}"
  name   = "accessPolicies/${data.google_access_context_manager_access_policy.access_policy.name}/servicePerimeters/secure_perimeter"
  title  = "Secure Perimeter"
  
  # ADDED: This flag is required when a 'spec' block is defined to
  # explicitly enable the dry-run mode configuration.
  use_explicit_dry_run_spec = true

  # The 'status' block defines the enforced configuration of the perimeter.
  # Projects to be protected and services to be restricted go inside this block.
  status {
    resources = ["projects/${var.project_id}"]

    # CORRECTED: You must provide a specific list of services to restrict.
    # The wildcard '*' is not allowed here.
    restricted_services = [
      "cloudresourcemanager.googleapis.com",
      "iam.googleapis.com",
      "serviceusage.googleapis.com",
      "cloudasset.googleapis.com"
    ]
  }

  # The 'spec' block defines the dry-run configuration. You can also place
  # resources and restricted_services here to test changes without enforcement.
  spec {
    # ADDED: The spec block also needs to know which resources and services
    # it applies to for the dry-run configuration.
    resources = ["projects/${var.project_id}"]

    # CORRECTED: The spec block also requires an explicit list of services.
    restricted_services = [
      "cloudresourcemanager.googleapis.com",
      "iam.googleapis.com",
      "serviceusage.googleapis.com",
      "cloudasset.googleapis.com"
    ]

    ingress_policies {
      ingress_from {
        sources {
          access_level = google_access_context_manager_access_level.console_access.name
        }
        identity_type = "ANY_IDENTITY"
      }

      ingress_to {
        operations {
          service_name = "cloudresourcemanager.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
        operations {
          service_name = "iam.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
        operations {
          service_name = "serviceusage.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
        operations {
          service_name = "billing.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
        operations {
          service_name = "cloudasset.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
        # Add other necessary services here based on your usage and audit logs
        # For example, to use the Compute Engine console:
        # operations {
        #   service_name = "compute.googleapis.com"
        #   method_selectors {
        #     method = "*"
        #   }
        # }
      }
    }
  }
}