job "httpd" {
  datacenters = ["toronto"]
  type = "system"
  group "httpd" {

    task "httpd" {
      driver = "docker"

      vault {
        policies = ["nomad-cs-de2"]
        change_mode   = "restart"
      }


      env {
       VAULT_ADDR = "172.16.1.1:8200"
      }

      config {
        image = "yext.httpd.base:0.1.0"
        port_map {
          http = 8080
        }
      }

      resources {
        network {
          port "http" {
              static = 8080
          }
        }
      }

    }
  }
}
