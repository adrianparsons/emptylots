resource "google_project_service" "apikeys" {
  project = google_project.empty_lots.project_id
  service = "apikeys.googleapis.com"

  disable_on_destroy = false
}

resource "google_apikeys_key" "maps_frontend" {
  # UUID of the existing console-created key. Changing this forces
  # replacement, which rotates the AIza... key string the frontend depends on.
  name         = var.maps_api_key_uid
  display_name = "Maps Platform API Key"
  project      = google_project.empty_lots.project_id

  restrictions {
    api_targets {
      service = "maps-backend.googleapis.com"
    }

    browser_key_restrictions {
      allowed_referrers = concat(
        [
          var.domain,
          "prod.${var.domain}",
          "static.${var.domain}",
        ],
        var.additional_allowed_referrers,
      )
    }
  }

  depends_on = [google_project_service.apikeys]
}

resource "google_apikeys_key" "pagespeed" {
  # UUID of the existing console-created key used by CI to call the PageSpeed
  # Insights API. Server-side use, so no browser referrer restrictions.
  name         = var.pagespeed_api_key_uid
  display_name = "PageSpeed Insights API Key"
  project      = google_project.empty_lots.project_id

  restrictions {
    api_targets {
      service = "pagespeedonline.googleapis.com"
    }
  }

  depends_on = [google_project_service.apikeys]
}

locals {
  # Mirrors the broad Maps Platform API surface enabled for the existing dev key.
  localhost_api_services = [
    "addressvalidation.googleapis.com",
    "aerialview.googleapis.com",
    "airquality.googleapis.com",
    "directions-backend.googleapis.com",
    "distance-matrix-backend.googleapis.com",
    "elevation-backend.googleapis.com",
    "geocoding-backend.googleapis.com",
    "geolocation.googleapis.com",
    "maps-android-backend.googleapis.com",
    "maps-backend.googleapis.com",
    "maps-embed-backend.googleapis.com",
    "maps-ios-backend.googleapis.com",
    "mapsplatformdatasets.googleapis.com",
    "navigationsdk.googleapis.com",
    "places-backend.googleapis.com",
    "places.googleapis.com",
    "pollen.googleapis.com",
    "roads.googleapis.com",
    "routeoptimization.googleapis.com",
    "routes.googleapis.com",
    "solar.googleapis.com",
    "static-maps-backend.googleapis.com",
    "street-view-image-backend.googleapis.com",
    "streetviewpublish.googleapis.com",
    "tile.googleapis.com",
    "timezone-backend.googleapis.com",
  ]
}

resource "google_apikeys_key" "maps_localhost" {
  # UUID of the existing console-created localhost dev key.
  name         = var.localhost_api_key_uid
  display_name = "Localhost key"
  project      = google_project.empty_lots.project_id

  restrictions {
    dynamic "api_targets" {
      for_each = toset(local.localhost_api_services)
      content {
        service = api_targets.value
      }
    }

    browser_key_restrictions {
      allowed_referrers = concat(
        [
          "http://localhost:8000",
          "http://localhost:1234",
        ],
        var.additional_localhost_referrers,
      )
    }
  }

  depends_on = [google_project_service.apikeys]
}
