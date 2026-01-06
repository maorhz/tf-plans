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

provider "google" {
  project = var.provider_project_id
  region  = var.region
}

variable "project_ids" {
  description = "List of project IDs to deploy to"
  type        = set(string)
  # Replace with your actual project IDs
  default     = ["p-gen-dfir", "my-project-76851-371010"] 
}

# 1. Enable the API for each project
resource "google_project_service" "net_sec_api" {
  for_each = var.project_ids

  project = each.value
  service = "networksecurity.googleapis.com"

  # Prevents accidental API disablement if you remove the resource from Terraform
  disable_on_destroy = false 
}

# 2. Create the DNS Threat Detector for each project
resource "google_network_security_dns_threat_detector" "default" {
  for_each = var.project_ids

  provider                 = google-beta
  name                     = "my-dns-armor-policy"
  location                 = "global"
  project                  = each.value
  threat_detector_provider = "INFOBLOX"

  # CRITICAL: Wait for the API to be enabled first
  depends_on = [google_project_service.net_sec_api] 
}