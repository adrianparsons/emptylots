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
}
