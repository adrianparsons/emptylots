resource "google_project" "empty_lots" {
  name            = var.project
  project_id      = var.project
  billing_account = var.billing_account
  org_id          = var.org_id

  lifecycle {
    prevent_destroy = true
  }
}
