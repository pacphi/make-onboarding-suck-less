data "oci_dns_zones" "root_zone" {
  compartment_id = var.compartment_ocid
  name = var.root_zone_name
}

resource "oci_dns_zone" "zone" {
  compartment_id = var.compartment_ocid
  name = "${var.dns_prefix}.${data.oci_dns_zones.root_zone[0].name}"
  zone_type = "PRIMARY"
}

resource "oci_dns_record" "ns_record" {
  zone_name_or_id = data.oci_dns_zones.root_zone[0].id
  domain = "${var.dns_prefix}.${data.oci_dns_zones.root_zone[0].name}"
  rtype = "NS"
  ttl = 30
}
