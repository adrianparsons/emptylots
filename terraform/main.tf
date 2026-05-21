terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }

  backend "gcs" {
    bucket = "empty-nyc-tfstate"
    prefix = "infra"
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone

  # Required for APIs like apikeys.googleapis.com that demand an explicit
  # quota/billing project on each request.
  billing_project       = var.project
  user_project_override = true
}
