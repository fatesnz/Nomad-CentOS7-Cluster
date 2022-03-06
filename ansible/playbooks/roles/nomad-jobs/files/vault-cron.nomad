job "vault-cron-v2" {
  datacenters = ["toronto"]

  type = "batch"

  periodic {
    cron             = "*/5 * * * * *"
    time_zone        = "UTC"
  }

  vault {
    policies = ["nomad-cs-de2"]
    change_mode   = "noop"
  }

  group "vault-cron" {
    count = 2

    task "output" {

       driver = "raw_exec"

       config {
         command = "echo"
         args = ["2"]
       }

       template {
          data = <<EOF
          secret:  "{{with secret "secret/consumer-serving/de2/foo"}}{{.Data.data}}{{end}}"
          EOF
          destination = "/tmp/out.txt"
        }
      }
    }
}
