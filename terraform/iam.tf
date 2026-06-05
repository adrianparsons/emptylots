# GitHub Actions authenticates to GCP with keyless Workload Identity Federation:
# the workflows call google-github-actions/auth with `workload_identity_provider`
# and no `service_account`, so the federated principal accesses resources directly.
# This file codifies the pool, the provider, and every IAM binding granted to that
# principal. All grants are additive (`_member`, never `_binding`/`_policy`) so
# Terraform never becomes the authoritative owner of these resource policies — it
# leaves the owner/editor/service-agent bindings it does not manage untouched.

# Required to manage Workload Identity Federation resources. Enabled out-of-band
# when the pool was first created via gcloud; adopted here so it's tracked.
resource "google_project_service" "iam" {
  project = google_project.empty_lots.project_id
  service = "iam.googleapis.com"

  disable_on_destroy = false
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"
  display_name              = "GitHub Actions Pool"

  depends_on = [google_project_service.iam]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "emptylots"
  display_name                       = "My GitHub repo Provider"

  # Only OIDC tokens from repositories under this GitHub owner may use the provider.
  attribute_condition = "assertion.repository_owner == '${var.github_owner}'"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Any identity from the github pool that passes the provider's owner condition.
# `.name` resolves to projects/<number>/locations/global/workloadIdentityPools/github,
# so this matches the live principalSet bindings exactly.
locals {
  github_principal = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/*"
}

# --- Project-level grants (dbt.yml reads/runs BigQuery) ---
resource "google_project_iam_member" "github_bigquery_data_viewer" {
  project = var.project
  role    = "roles/bigquery.dataViewer"
  member  = local.github_principal
}

resource "google_project_iam_member" "github_bigquery_user" {
  project = var.project
  role    = "roles/bigquery.user"
  member  = local.github_principal
}

# --- nyc-lots-tiles bucket (build-and-deploy-tiles.yml uploads tiles) ---
resource "google_storage_bucket_iam_member" "github_tiles_object_creator" {
  bucket = google_storage_bucket.nyc_lots_tiles.name
  role   = "roles/storage.objectCreator"
  member = local.github_principal
}

resource "google_storage_bucket_iam_member" "github_tiles_object_user" {
  bucket = google_storage_bucket.nyc_lots_tiles.name
  role   = "roles/storage.objectUser"
  member = local.github_principal
}

resource "google_storage_bucket_iam_member" "github_tiles_object_viewer" {
  bucket = google_storage_bucket.nyc_lots_tiles.name
  role   = "roles/storage.objectViewer"
  member = local.github_principal
}

# --- nyc-lots-web bucket (frontend.yml uploads the static site) ---
resource "google_storage_bucket_iam_member" "github_web_object_user" {
  bucket = google_storage_bucket.nyc_lots_web.name
  role   = "roles/storage.objectUser"
  member = local.github_principal
}

resource "google_storage_bucket_iam_member" "github_web_object_viewer" {
  bucket = google_storage_bucket.nyc_lots_web.name
  role   = "roles/storage.objectViewer"
  member = local.github_principal
}
