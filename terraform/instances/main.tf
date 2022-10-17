terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
  type = string
}

variable "do_region" {
  type = string
}

variable "reverse_proxy_public_ip" {
  type = string
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_droplet_snapshot" "reverse_proxy_snapshot" {
  name_regex  = "^packer-reverse-proxy"
  region      = var.do_region
  most_recent = true
}

resource "digitalocean_droplet" "reverse_proxy_test" {
  image  = data.digitalocean_droplet_snapshot.reverse_proxy_snapshot.id
  region = var.do_region
  size   = "s-1vcpu-1gb"
  name   = "reverse-proxy-test"
}

resource "digitalocean_reserved_ip_assignment" "reverse_proxy_ip_assignment" {
  ip_address = var.reverse_proxy_public_ip
  droplet_id = digitalocean_droplet.reverse_proxy_test.id
}
