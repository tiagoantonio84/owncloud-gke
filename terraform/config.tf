provider "google" {
  credentials = "${file("/path/to/account.json")}"
  project     = "google-project"
  region      = "${var.region}"
}
