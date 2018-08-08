resource "google_sql_database_instance" "owncloud" {
  name             = "${var.cloudsql_name}"
  database_version = "${var.database_version}"
  region           = "${var.region}"

  settings {
    tier      = "${var.mysql_size_instance}"
    disk_size = "${var.mysql_disk_size}"

    backup_configuration {
      enabled    = "true"
      start_time = "23:00"
    }

    database_flags {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  }
}

resource "google_sql_database" "owncloud-db" {
  name      = "${var.database_name}"
  instance  = "${google_sql_database_instance.owncloud.name}"
  charset   = "utf8mb4"
  collation = "utf8mb4_bin"
}

resource "google_sql_user" "users" {
  name     = "${var.database_user}"
  instance = "${google_sql_database_instance.owncloud.name}"
  password = "${var.database_password}"
}

resource "google_sql_user" "proxy_users" {
  name     = "${var.proxy_user}"
  host     = "cloudsqlproxy~%"
  instance = "${google_sql_database_instance.owncloud.name}"
  password = "${var.proxy_password}"
}
