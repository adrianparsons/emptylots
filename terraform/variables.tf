variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-c"
}

variable "billing_account" {
  description = "GCP billing account ID"
  type        = string
  sensitive   = true
}

variable "org_id" {
  description = "GCP organization ID"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Primary domain. CDN is served at cdn.<domain>."
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for project storage buckets (e.g. \"my-app\" yields \"my-app-web\", \"my-app-tiles\")."
  type        = string
}
