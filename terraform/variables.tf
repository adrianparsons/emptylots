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
