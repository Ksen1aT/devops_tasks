terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.0"
    }
  }
}

provider "docker" {
  host     = "ssh://student@111.88.162.83:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

resource "docker_image" "nginx" {
  name = "nginx:1.25-alpine"
}

resource "docker_network" "app_network" {
  name   = "app-network"
  driver = "bridge"
}

resource "docker_volume" "nginx_data" {
  name = "nginx-data"
}

resource "docker_container" "nginx" {
  name  = "nginx-web"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8080
    protocol = "tcp"
  }

  networks_advanced {
    name    = docker_network.app_network.name
    aliases = ["nginx", "web"]
  }

  volumes {
    volume_name    = docker_volume.nginx_data.name
    container_path = "/usr/share/nginx/html"
  }

  restart  = "unless-stopped"
  must_run = true
}

output "nginx_url" {
  value = "http://111.88.162.83:8080"
}
