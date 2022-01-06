output "zone_name" {
  value = oci_dns_zone.zone.name
}

output "zone_subdomain" {
  value = trim(oci_dns_zone.zone.name, ".")
}