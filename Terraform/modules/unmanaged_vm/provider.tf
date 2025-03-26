provider "ocean" {
  tenant_id      = "****"
  tenant_slug    = "****"
  space_name     = "****"
  oidc_base      = "****"
  ocean_endpoint = "****"
  poll_interval  = "3s"
}

terraform {
  required_providers {
    ocean = {
      source  = "ocean/ocean"
      version = "0.3.2"
    }
  }
}
