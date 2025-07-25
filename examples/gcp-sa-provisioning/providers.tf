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
  region                      = var.google_region
}
