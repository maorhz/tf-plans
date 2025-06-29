# --------------------
# Variable Definitions
# --------------------
variable "region" {
  description = "The GCP region for the provider."
  type        = string
  default     = ""
}

variable "organization_id" {
  description = "The ID of the Google Cloud Organization."
  type        = string
  default     = ""
}

variable "provider_project_id" {
  description = "The GCP project ID for the provider's operational context. This project is used for API calls and state management."
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "The ID of the folder to be protected (scoped) by the perimeter."
  type        = string
  default     = ""
}

variable "project_id" {
  description = "The ID of the project to be protected (scoped) by the perimeter."
  type        = string
  default     = ""
}

variable "policy_title" {
  description = "The title of the Access Context Manager Policy."
  type        = string
  default     = ""
}

variable "perimeter_title" {
  description = "The title of the VPC Service Controls perimeter."
  type        = string
  default     = ""
}

variable "restricted_services" {
  description = "A list of services to be protected by the perimeter."
  type        = list(string)
  default     = []
}

 variable "allowed_cidr" {
  description = "A list of IP CIDR range/s to allow access from."
  type        = list(string)
  default     = []
}

 variable "limitted_cidr" {
  description = "A list of limitted IP CIDR range/s to allow access from."
  type        = list(string)
  default     = []
}

variable "privileged_service_accounts" {
  description = "The service accounts considered to have high privileges."
  type        = string
  default     = ""
}