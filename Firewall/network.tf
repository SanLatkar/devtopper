resource "digitalocean_vpc" "dev" {
    name = "dev-vpc"

    region = var.region

    ip_range = "192.168.44.0/24"

}