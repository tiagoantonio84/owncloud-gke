provider "google" {
  credentials = "${file("~/account1.json")}"
  project     = "google-project"
  region      = "${var.region}"
}
