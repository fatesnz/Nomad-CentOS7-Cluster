job "redis-vault" {
  datacenters = ["toronto"]

  group "cache" {

    count = 4

    task "redis" {
      driver = "docker"

      vault {
        policies = ["nomad-cs-de2"]
        change_mode   = "noop"
      }

      env {
       VAULT_ADDR = "172.16.1.1:8200"
      }

      config {
        image = "redis:3.2"
      }

      resources {
        cpu    = 500
        memory = 256
      }

      template {
        change_mode   = "noop"
        data = <<EOF
supersecret = "{{with secret "secret/consumer-serving/de2/foo"}}{{.Data.data}}{{end}}"
EOF
        destination   = "secrets/file"
      }

    }
  }
}
