resource "google_project_service" "bigquery" {
  project = google_project.empty_lots.project_id
  service = "bigquery.googleapis.com"

  disable_on_destroy = false
}

# Raw vendored PLUTO / MapPLUTO source data, loaded from the CSV/GeoJSON
# snapshots in gs://nyc-lots-raw-data (not built by dbt). Kept separate from
# the dataset dbt writes models into, so raw vs. derived is unambiguous.
resource "google_bigquery_dataset" "raw_pluto" {
  dataset_id  = "raw_pluto"
  project     = google_project.empty_lots.project_id
  location    = "us-east4"
  description = "Raw vendored PLUTO / MapPLUTO source data (loaded from CSV/GeoJSON, not dbt-built)."

  depends_on = [google_project_service.bigquery]
}

# Raw vendored NYC Department of Buildings open data (permit issuance, stalled
# construction, building footprints), loaded from CSV snapshots — not dbt-built.
resource "google_bigquery_dataset" "raw_dob" {
  dataset_id  = "raw_dob"
  project     = google_project.empty_lots.project_id
  location    = "us-east4"
  description = "Raw vendored NYC DOB open data (loaded from CSV snapshots, not dbt-built)."

  depends_on = [google_project_service.bigquery]
}
