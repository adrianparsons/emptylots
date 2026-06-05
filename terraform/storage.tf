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

# Raw vendored source data: PLUTO CSVs, MapPLUTO geometry, and DOB CSVs that the
# build/ scripts upload to and `bq load` reads from. Located in us-east4 to
# co-locate with the raw_pluto / raw_dob datasets so loads stay in-region.
#
# vendor.* overwrites each snapshot in place, so object versioning keeps the
# history of what was pulled when (the live object is always the latest pull).
# The lifecycle rule caps cost by expiring superseded versions after 90 days.
resource "google_storage_bucket" "nyc_lots_raw" {
  name     = "${var.bucket_prefix}-raw-data"
  location = "US-EAST4"

  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 90
    }
    action {
      type = "Delete"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Legacy raw-data bucket. Misnamed (holds more than historical PLUTO) and not on
# the `${var.bucket_prefix}-` convention; superseded by nyc_lots_raw above.
# Retained until its contents are migrated, then can be removed.
resource "google_storage_bucket" "nyc_pluto_historical" {
  name          = "nyc-pluto-historical"
  location      = "US"
  force_destroy = true
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
