variable "image" {
  type = string
  default = "postgres:13"
}

job "postgres" {
  datacenters = ["dc1"]
  type        = "service"

  group "postgres-group" {
    count = 1

    network {
      port "db" {
        to = 5432
      }
    }

    task "postgres-task" {
      driver = "podman"

      config {
        network_mode = "bridge"
        image        = var.image
        ports        = ["db"]
      }

      env {
        POSTGRESQL_PASSWORD = ""
      }

      resources {
        cpu    = 350
        memory = 500
      }

      service {
        tags = [
          "postgresqldb"
        ]

        name         = "postgres-service"
        port         = "db"
        provider     = "nomad"
        address_mode = "driver"

        check {
          type     = "tcp"
          port     = "db"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
