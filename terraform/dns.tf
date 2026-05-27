resource "google_dns_managed_zone" "empty_nyc" {
  name        = "empty-nyc"
  dns_name    = "${var.domain}."
  description = "Public zone for ${var.domain}"
}

resource "google_dns_record_set" "apex_a" {
  name         = "${var.domain}."
  managed_zone = google_dns_managed_zone.empty_nyc.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_forwarding_rule.cdn_empty_frontend.ip_address]
}

resource "google_dns_record_set" "subdomain_a" {
  for_each = toset(["www", "prod", "cdn", "static"])

  name         = "${each.key}.${var.domain}."
  managed_zone = google_dns_managed_zone.empty_nyc.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_forwarding_rule.cdn_empty_frontend.ip_address]
}

resource "google_dns_record_set" "atproto_txt" {
  name         = "_atproto.${var.domain}."
  managed_zone = google_dns_managed_zone.empty_nyc.name
  type         = "TXT"
  ttl          = 3600
  rrdatas      = ["\"did=did:plc:5wmwpdxigril7gqurm7igwwn\""]
}
