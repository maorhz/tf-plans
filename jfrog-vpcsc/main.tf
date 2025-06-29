# This HCL file is unsupported and does not affiliate with any Google commercial nor open-source project, product, or service.
# Adjust it as needed and use this plan with cautious as a template or example to implement policy using gcp vpc service controls.

# ------------------------
# Provider Configuration
# ------------------------
provider "google" {
  project = var.provider_project_id
  region  = var.region
}

# ------------------------------------------------------------------------------
# Access Context Manager Policy
# ------------------------------------------------------------------------------
# Organization level policy
resource "google_access_context_manager_access_policy" "access_policy" {
  parent = "organizations/${var.organization_id}"
  title  = var.policy_title
}

# ------------------------------------------------------------------------------
# Service Perimeter
# ------------------------------------------------------------------------------
resource "google_access_context_manager_service_perimeter" "jfrog_perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}/servicePerimeters/prmt_jfrog"
  title  = var.perimeter_title

  perimeter_type = "PERIMETER_TYPE_REGULAR"

  status {
  # Projects to protect (included in the perimeter).
    resources = ["projects/${var.project_id}"]
  # Services to protect (included in the perimeter).
    restricted_services = var.restricted_services

    access_levels = [
      google_access_context_manager_access_level.any_sa_except_hpriv_from_ip.name,
      google_access_context_manager_access_level.hpriv_sa_from_ip.name,
    ]
  }
  
  depends_on = [
    google_access_context_manager_access_level.any_sa_except_hpriv_from_ip,
    google_access_context_manager_access_level.hpriv_sa_from_ip,
  ]
}

# ------------------------------------------------------------------------------
# Access Level 1: Any identity (except high-priv) from a specific ip addresses
# ------------------------------------------------------------------------------
resource "google_access_context_manager_access_level" "any_sa_except_hpriv_from_ip" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}/accessLevels/anySaExceptHprivFromIp"
  title  = "Any identity except from high-priv sa"

  basic {
    combining_function = "AND"
    conditions {
      ip_subnetworks = var.allowed_cidr
    }
    conditions {
      negate  = true
      members = [var.privileged_service_accounts]
    }
  }
}

# ----------------------------------------------------------------------------
# Access Level 2: Specific sa from authorized/limittedted ip addresses
# ----------------------------------------------------------------------------
# Allow access to high-priv sa from authorized (limitted) ip addresses
resource "google_access_context_manager_access_level" "hpriv_sa_from_ip" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}/accessLevels/hprivSaFromIp"
  title  = "High-priv sa from authoized (limitted) ip addreses"
  
  basic {
    conditions {
      ip_subnetworks = var.limitted_cidr
      members = [
        "serviceAccount:sa1test@p-prd-app1.iam.gserviceaccount.com"
      ]
    }
  }
}