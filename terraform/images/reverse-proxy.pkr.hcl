packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.4"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

variable "do_token" {
  type = string
}

variable "do_region" {
  type = string
}

variable "wireguard_server_private_key" {
  type = string
}

variable "nuc_public_key" {
  type = string
}

variable "desktop_public_key" {
  type = string
}

variable "mac_public_key" {
  type = string
}

source "digitalocean" "reverse-proxy" {
  api_token      = var.do_token
  image          = "ubuntu-22-04-x64"
  snapshot_name  = "packer-reverse-proxy"
  region         = var.do_region
  size           = "s-1vcpu-1gb"
  ssh_username   = "root"
  droplet_name   = "reverse-proxy-builder"
  user_data_file = "./config/cloud-config.yml"
}

build {
  sources = ["source.digitalocean.reverse-proxy"]

  # Configure firewall
  provisioner "shell" {
    script = "./scripts/configure-firewall.sh"
  }

  # Configure sysctl 
  provisioner "file" {
    source      = "./config/sysctl/99-custom.conf"
    destination = "/etc/sysctl.d/99-custom.conf"
  }

  # Install packages
  provisioner "shell" {
    script = "./scripts/install-packages.sh"
  }

  # Add wireguard configuration
  provisioner "file" {
    content = templatefile("../config/wireguard/home.conf.tftpl", {
      wireguard_server_private_key = var.wireguard_server_private_key,
      nuc_public_key               = var.nuc_public_key,
      desktop_public_key           = var.desktop_public_key,
      mac_public_key               = var.mac_public_key,
    })
    destination = "/etc/wireguard/home.conf"
  }

  provisioner "shell" {
    inline = [
      "sudo systemctl enable wg-quick@home"
    ]
  }

  # Set outbound traffic config
  provisioner "file" {
    source      = "./config/systemd/outbound-traffic-config.service"
    destination = "/etc/systemd/system/outbound-traffic-config.service"
  }

  provisioner "shell" {
    inline = [
      "sudo systemctl enable outbound-traffic-config.service"
    ]
  }

  # Set up reverse proxies for publicly exposed services
  provisioner "file" {
    source      = "./config/systemd/minecraft-proxy.service"
    destination = "/etc/systemd/system/minecraft-proxy.service"
  }

  provisioner "shell" {
    inline = [
      "sudo systemctl enable minecraft-proxy.service"
    ]
  }

}
