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

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.provider_project_id
  region  = var.region
}

## Access Context Manager Policy ##
#  Org level policy (required to avoid unexpected behaviour)
resource "google_access_context_manager_access_policy" "access_policy" {
  parent = "organizations/${var.organization_id}"
  title  = var.policy_title
}

## Service Perimeter (Dry-Run) ##
resource "google_access_context_manager_service_perimeter" "jfrog_perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}/servicePerimeters/pmtr_a"
  title  = var.perimeter_title

  perimeter_type = "PERIMETER_TYPE_REGULAR"

# Enforce mode (blank when using dry-run mode)
  status {
    resources = []
  }
  
# Dry-run mode
  use_explicit_dry_run_spec = true
  spec {
    resources           = ["projects/${var.project_id}"]
    restricted_services = var.restricted_services

    access_levels = [
      google_access_context_manager_access_level.any_idnt_except_hpriv.name,
      google_access_context_manager_access_level.hpriv_sa_from_ip.name,
    ]
  }

  depends_on = [
    google_access_context_manager_access_level.any_idnt_except_hpriv,
    google_access_context_manager_access_level.hpriv_sa_from_ip,
  ]
}

## Access Levels ## 
# Acess Level 1: Any identity EXCEPT from high-priv sa (optiona - from specific ip addresses)
resource "google_access_context_manager_access_level" "any_idnt_except_hpriv" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}/accessLevels/anyIdntExceptHprivSaFromIp"
  title  = "Any identity except from high-priv sa"

  basic {
#      combining_function = "AND"
#      conditions {
#      ip_subnetworks = var.allowed_cidr
#    }
    conditions {
      negate  = true
      members = var.excld_principal
    }
  }
}

# Access Level 2: Specific sa from authorized/limited ip addresses
resource "google_access_context_manager_access_level" "hpriv_sa_from_ip" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}/accessLevels/hprivSaFromIp"
  title  = "High-priv sa from authorized (limited) ip addreses"

  basic {
    conditions {
      ip_subnetworks = var.limited_cidr
      members        = var.hpriv_principal
    }
  }
  depends_on = [
    google_access_context_manager_access_level.any_idnt_except_hpriv,
  ]
}