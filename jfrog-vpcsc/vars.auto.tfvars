# ------------------------------------------------------
# Assigns values to the variables declared in .tf files.
# ------------------------------------------------------
region                      = "me-west1"
organization_id             = "323910511922"
provider_project_id         = "my-project-76851-371010"
folder_id                   = "12476811698"                         # scoped folder    
project_id                  = "1022605794612"                       # scoped project
policy_title                = "ACM_POLICY"
perimeter_title             = "prmtr_a"
restricted_services         = ["storage.googleapis.com"]
limitted_cidr               = ["44.202.22.235/32"]                  # multpile values >> ["44.202.22.235/32", "93.173.47.135/32"]
allowed_cidr                = ["93.173.47.135/32"]
privileged_service_accounts = "serviceAccount:sa1test@p-prd-app1.iam.gserviceaccount.com"