terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_volume" "my_volume" {
  name = "my_volume"
}

resource "docker_network" "my_network" {
  name = "my_network"
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "${var.container_name}"
  ports {
    internal = 80
    external = 8001
  }
  env = [
    "MY_ENV_VAR=my_env_value"
  ]
  volumes {
    volume_name = docker_volume.my_volume.name
    container_path = "/usr/share/nginx/html"
  }
  networks_advanced {
    name = docker_network.my_network.name
  }
}
