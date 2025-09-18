terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project                     = var.google_project
  region                      = var.region
  impersonate_service_account = var.google_service_account
}

provider "databricks" {
  host                   = "https://accounts.gcp.databricks.com"
  account_id             = var.databricks_account_id
  google_service_account = var.google_service_account
}
