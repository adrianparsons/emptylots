resource "google_storage_bucket" "nyc_lots_web" {
  name     = "nyc-lots-web"
  location = var.region

  lifecycle {
    prevent_destroy = true
  }
}
