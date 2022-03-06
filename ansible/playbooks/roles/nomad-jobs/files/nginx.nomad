job "nginx" {
  datacenters = ["toronto"]
  type = "service"
  group "nginx" {
    count = 2
    task "nginx" {
      driver = "docker"

      vault {
        policies = ["nomad-cs-de2"]
        change_mode   = "noop"
      }

      config {
        image = "nginx"
        port_map {
          http = 8080
        }
        port_map {
          https = 443
        }
        volumes = [
          "custom/default.conf:/etc/nginx/conf.d/default.conf"
        ]
      }
      template {
        change_mode   = "noop"
        data = <<EOH
          server {
            listen 8080;
            server_name nginx.service.consul;
            location /nginx {
              root /local/data;
            }
          }
        EOH
        destination = "custom/default.conf"
      }
      # consul kv put features/demo 'Consul Rocks!'
     template {
        data = <<EOH
        secret:  "{{with secret "secret/consumer-serving/de2/foo"}}{{.Data.data}}{{end}}"
        EOH
        destination = "local/data/nginx/index.html"
      }
      resources {
        cpu    = 100 # 100 MHz
        memory = 128 # 128 MB
        network {
          mbits = 10
          port "http" {
              static = 8080
          }
          port "https" {
              static= 443
          }
        }
      }
      service {
        name = "nginx"
        tags = [ "nginx", "web", "urlprefix-/nginx" ]
        port = "http"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
