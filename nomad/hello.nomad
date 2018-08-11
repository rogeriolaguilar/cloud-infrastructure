job "helloworld" {
  datacenters = ["dc1"]
  type = "service"

  update {
    max_parallel = 1
  }

  group "hello-group" {
    count = 2
    task "hello-task" {
      driver = "docker"
      config {
        image = "heroku/nodejs-hello-world"
        port_map {
          http = 3000
        }
      }
      resources {
        cpu = 100
        memory = 200
        network {
          mbits = 1
          port "http" {
            static = "80"
          }
        }
      }
    }
  }
}
