data "google_compute_zones" "available-updated" {}

resource "google_container_cluster" "owncloud" {
  name               = "${var.cluster_name}"
  zone               = "${var.zone_aza}"
  network            = "${var.network_name}"
  subnetwork         = "${var.subnet1_name}"
  enable_legacy_abac = "${var.legacy_auth}"
  node_version       = "${var.ks8_version}"
  min_master_version = "${var.ks8_version}"
  initial_node_count = 1

  master_auth {
    username = "${var.k8s-username}"
    password = "${var.k8s-password}"
  }

  node_config {
    machine_type = "${var.node_size}"

    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "logging-write",
      "monitoring",
    ]
  }
}
