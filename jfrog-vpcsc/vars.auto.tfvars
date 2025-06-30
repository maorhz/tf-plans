# ------------------------
# Variables assignment
# ------------------------
region                      = "me-west1"
organization_id             = "323910511922"
provider_project_id         = "my-project-76851-371010"
folder_id                   = "12476811698"                         # scoped folder    
project_id                  = "1022605794612"                       # scoped project
policy_title                = "acm_policy"
perimeter_title             = "pmtr_a"
restricted_services         = ["storage.googleapis.com"]
limitted_cidr               = ["44.202.22.235/32"]        # multpile values >> ["44.202.22.235/32", "2620:0:1045:1f:4c94:ee6b:1bdc:9a65/128"]
allowed_cidr                = ["2620:0:1045:1f:887f:901c:3d5a:e720/128", "93.173.47.135/32"]
hpriv_principal = [
  "serviceAccount:sa1test@p-prd-app1.iam.gserviceaccount.com",
  "user:admin@maorhz.altostrat.com"
]