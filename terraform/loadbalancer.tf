resource "google_compute_backend_bucket" "emptynyc" {
  name             = "emptynyc"
  bucket_name      = google_storage_bucket.nyc_lots_tiles.name
  enable_cdn       = true
  compression_mode = "DISABLED"
}

resource "google_compute_backend_bucket" "emptynyc_web" {
  name             = "emptynyc-web"
  bucket_name      = google_storage_bucket.nyc_lots_web.name
  enable_cdn       = false
  compression_mode = "DISABLED"
}

resource "google_compute_url_map" "nyc_lots_tiles" {
  name            = "nyc-lots-tiles"
  default_service = google_compute_backend_bucket.emptynyc.self_link

  host_rule {
    hosts        = ["static.${var.domain}"]
    path_matcher = "static"
  }

  host_rule {
    hosts        = [var.domain, "prod.${var.domain}"]
    path_matcher = "apex"
  }

  host_rule {
    hosts        = ["www.${var.domain}"]
    path_matcher = "www-redirect"
  }

  path_matcher {
    name            = "static"
    default_service = google_compute_backend_bucket.emptynyc_web.self_link
  }

  path_matcher {
    name            = "apex"
    default_service = google_compute_backend_bucket.emptynyc_web.self_link

    default_route_action {
      url_rewrite {
        path_prefix_rewrite = "/main"
      }
    }
  }

  path_matcher {
    name = "www-redirect"

    default_url_redirect {
      host_redirect          = var.domain
      redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
      strip_query            = false
      https_redirect         = true
    }
  }
}

resource "google_compute_managed_ssl_certificate" "cdn_emptynyc" {
  name = "cdn-emptynyc"
  type = "MANAGED"
  managed {
    domains = ["cdn.${var.domain}"]
  }
}

resource "google_compute_managed_ssl_certificate" "static_emptynyc" {
  name = "static-emptynyc"
  type = "MANAGED"
  managed {
    domains = ["static.${var.domain}"]
  }
}

resource "google_compute_managed_ssl_certificate" "apex_emptynyc" {
  name = "apex-emptynyc-2"
  type = "MANAGED"
  managed {
    domains = [var.domain, "www.${var.domain}"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_managed_ssl_certificate" "prod_emptynyc" {
  name = "prod-emptynyc"
  type = "MANAGED"
  managed {
    domains = ["prod.${var.domain}"]
  }
}

resource "google_compute_url_map" "http_redirect" {
  name = "http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "nyc_lots_tiles" {
  name    = "nyc-lots-tiles-target-proxy"
  url_map = google_compute_url_map.http_redirect.self_link
}

resource "google_compute_global_address" "cdn_empty_frontend" {
  name    = "cdn-empty-frontend-ip"
  address = var.lb_ip
}

resource "google_compute_global_forwarding_rule" "cdn_empty_frontend_http" {
  name                  = "cdn-empty-frontend-http"
  target                = google_compute_target_http_proxy.nyc_lots_tiles.self_link
  ip_address            = google_compute_global_address.cdn_empty_frontend.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80-80"
}

resource "google_compute_target_https_proxy" "nyc_lots_tiles" {
  name    = "nyc-lots-tiles-target-proxy-2"
  url_map = google_compute_url_map.nyc_lots_tiles.self_link
  ssl_certificates = [
    google_compute_managed_ssl_certificate.cdn_emptynyc.self_link,
    google_compute_managed_ssl_certificate.static_emptynyc.self_link,
    google_compute_managed_ssl_certificate.apex_emptynyc.self_link,
    google_compute_managed_ssl_certificate.prod_emptynyc.self_link,
  ]
  quic_override  = "NONE"
  tls_early_data = "DISABLED"
}

resource "google_compute_global_forwarding_rule" "cdn_empty_frontend" {
  name                  = "cdn-empty-frontend"
  target                = google_compute_target_https_proxy.nyc_lots_tiles.self_link
  ip_address            = google_compute_global_address.cdn_empty_frontend.address
  ip_protocol           = "TCP"
  ip_version            = "IPV4"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443-443"
}
