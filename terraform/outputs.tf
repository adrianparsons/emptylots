output "dns_nameservers" {
  description = "Point your registrar at these nameservers to activate Cloud DNS for empty.nyc."
  value       = google_dns_managed_zone.empty_nyc.name_servers
}
