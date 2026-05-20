resource "google_compute_backend_bucket" "emptynyc" {
  name             = "emptynyc"
  bucket_name      = google_storage_bucket.nyc_lots_tiles.name
  enable_cdn       = true
  compression_mode = "DISABLED"
}

resource "google_compute_url_map" "nyc_lots_tiles" {
  name            = "nyc-lots-tiles"
  default_service = google_compute_backend_bucket.emptynyc.self_link
}

resource "google_compute_managed_ssl_certificate" "cdn_emptynyc" {
  name = "cdn-emptynyc"
  type = "MANAGED"
  managed {
    domains = ["cdn.${var.domain}"]
  }
}

resource "google_compute_target_http_proxy" "nyc_lots_tiles" {
  name    = "nyc-lots-tiles-target-proxy"
  url_map = google_compute_url_map.nyc_lots_tiles.self_link
}

resource "google_compute_target_https_proxy" "nyc_lots_tiles" {
  name             = "nyc-lots-tiles-target-proxy-2"
  url_map          = google_compute_url_map.nyc_lots_tiles.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.cdn_emptynyc.self_link]
  quic_override    = "NONE"
  tls_early_data   = "DISABLED"
}

resource "google_compute_global_forwarding_rule" "cdn_empty_frontend" {
  name                  = "cdn-empty-frontend"
  target                = google_compute_target_https_proxy.nyc_lots_tiles.self_link
  ip_address            = "34.54.115.250"
  ip_protocol           = "TCP"
  ip_version            = "IPV4"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443-443"
}

resource "google_compute_global_forwarding_rule" "nyc_lots_tiles_ipv4" {
  name                  = "nyc-lots-tiles-forwarding-rule-ipv4"
  target                = google_compute_target_http_proxy.nyc_lots_tiles.self_link
  ip_address            = "34.149.219.106"
  ip_protocol           = "TCP"
  ip_version            = "IPV4"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80-80"
}

resource "google_compute_global_forwarding_rule" "nyc_lots_tiles_ipv6" {
  name                  = "nyc-lots-tiles-forwarding-rule-ipv6"
  target                = google_compute_target_http_proxy.nyc_lots_tiles.self_link
  ip_address            = "2600:1901:0:f058::"
  ip_protocol           = "TCP"
  ip_version            = "IPV6"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80-80"
}
