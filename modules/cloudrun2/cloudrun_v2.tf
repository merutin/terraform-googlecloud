data "google_project" "default" {}

resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }
    timeout                          = "300s"
    max_instance_request_concurrency = 1

    containers {
      image = var.image
      startup_probe {
        initial_delay_seconds = 0
        timeout_seconds       = 1
        period_seconds        = 3
        failure_threshold     = 1
        tcp_socket {
          port = 8080
        }
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "1G"
        }
        startup_cpu_boost = false
        cpu_idle          = true
      }
      liveness_probe {
        http_get {
          path = "/"
        }
      }
      env {
        name  = "INSTANCE_UNIX_SOCKET"
        value = format("/cloudsql/%s", var.connection_name)
      }
      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = var.connection_name
      }
      env {
        name  = "DB_NAME"
        value = "quickstart-db"
      }
      env {
        name  = "DB_USER"
        value = "quickstart-user"
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.connection_name]
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]
}

resource "google_project_iam_member" "default" {
  project = data.google_project.default.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${data.google_project.default.number}-compute@developer.gserviceaccount.com"
}
