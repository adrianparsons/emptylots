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
  description = "Primary domain. Tiles CDN is served at cdn.<domain>; static frontend is served at static.<domain>."
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for project storage buckets (e.g. \"my-app\" yields \"my-app-web\", \"my-app-tiles\")."
  type        = string
}

variable "github_owner" {
  description = "GitHub account/org that owns the repos allowed to authenticate via the Workload Identity Federation provider (matched against the OIDC token's repository_owner claim)."
  type        = string
}

variable "maps_api_key_uid" {
  description = "UUID of the existing Google Maps Platform API key (from `gcloud services api-keys list`). Imported, not created — changing this would force replacement and rotate the key string used by the frontend."
  type        = string
}

variable "additional_allowed_referrers" {
  description = "Extra HTTP referrer patterns allowed to use the Maps API key, beyond the primary domain and its `prod.` subdomain."
  type        = list(string)
  default     = []
}

variable "localhost_api_key_uid" {
  description = "UUID of the existing Localhost Google Maps Platform API key (from `gcloud services api-keys list`). Imported, not created."
  type        = string
}

variable "additional_localhost_referrers" {
  description = "Extra HTTP referrer patterns allowed to use the localhost dev key, beyond `http://localhost:8000` and `http://localhost:1234` (e.g. your machine's `.local` hostnames)."
  type        = list(string)
  default     = []
}

variable "pagespeed_api_key_uid" {
  description = "UUID of the existing PageSpeed Insights API key (from `gcloud services api-keys list`). Imported, not created — changing this would force replacement and rotate the key string used by CI."
  type        = string
}

variable "lb_ip" {
  description = "Reserved static IPv4 address for the load balancer (handles both port 80 and 443)."
  type        = string
}
