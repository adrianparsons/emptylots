resource "google_storage_bucket" "nyc_lots_web" {
  name     = "${var.bucket_prefix}-web"
  location = var.region

  website {
    main_page_suffix = "index.html"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Source PLUTO historical data archive. Name is literal (does not follow the
# `${var.bucket_prefix}-` convention used by the buckets this app provisions).
resource "google_storage_bucket" "nyc_pluto_historical" {
  name     = "nyc-pluto-historical"
  location = "US"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket" "nyc_lots_tiles" {
  name     = "${var.bucket_prefix}-tiles"
  location = "US-EAST4"

  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"

  soft_delete_policy {
    retention_duration_seconds = 0
  }

  cors {
    origin          = ["http://localhost:1234"]
    method          = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 0
  }

  cors {
    origin          = ["https://${var.domain}"]
    method          = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }

  cors {
    origin          = ["https://static.${var.domain}"]
    method          = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }

  cors {
    origin          = ["https://prod.${var.domain}"]
    method          = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }

  lifecycle {
    prevent_destroy = true
  }
}
