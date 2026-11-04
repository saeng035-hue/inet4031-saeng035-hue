resource "kubernetes_deployment_v1" "db_exporter" {
  metadata {
    name   = "db-exporter"
    labels = { app = "db-exporter" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "db-exporter" }
    }

    template {
      metadata {
        labels = { app = "db-exporter" }
      }

      spec {
        container {
          name  = "db-exporter"
          image = "quay.io/prometheuscommunity/postgres-exporter:v0.20.1"

          port {
            container_port = 9187
          }

          resources {
            requests = {
              cpu    = "25m"
              memory = "32Mi"
            }

            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          env {
            name  = "DATA_SOURCE_URI"
            value = "db:5432/${kubernetes_config_map_v1.app_config.data["POSTGRES_DB"]}?sslmode=disable"
          }

          env {
            name  = "DATA_SOURCE_USER"
            value = kubernetes_config_map_v1.app_config.data["POSTGRES_USER"]
          }

          env {
            name = "DATA_SOURCE_PASS"

            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.app_secrets.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "db_exporter" {
  metadata {
    name = "db-exporter"

    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "9187"
      "prometheus.io/path"   = "/metrics"
    }
  }

  spec {
    selector = { app = "db-exporter" }

    port {
      port        = 9187
      target_port = 9187
    }
  }
}
