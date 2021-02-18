resource "digitalocean_droplet" "dev" {

    count = var.droplet_count

    image = var.image

    name = "dev-${var.name}-${var.region}-${count.index +1}"

    region = var.region

    size = var.droplet_size

    ssh_keys = [var.ssh_fingerprint]

    vpc_uuid = digitalocean_vpc.dev.id

    tags = ["${var.name}-webserver"]

    private_networking = true

   // user_data = file("C:/Users/DELL/Documents/dev/Firewall/user-data.sh")

   /* user_data = <<EOF
    #cloud-config
    packages:
        - nginx
        - postgresql
        - postgresql-contrib
    runcmd:
        - wget -P /var/www/html https://raw.githubusercontent.com/do-community/terraform-sample-digitalocean-architectures/master/01-minimal-web-db-stack/assets/index.html
        - sed -i "s/CHANGE_ME/web-${var.region}-${count.index +1}/" /var/www/html/index.html
    EOF */


    connection {
		host = self.ipv4_address
		user = "root"
		type = "ssh"
		private_key = file("C:/Users/DELL/.ssh/dokey")
		timeout = "2m"
	}

    provisioner "remote-exec" {
		inline = [
			# install nginx
			"sudo apt-get update",
			"sudo apt-get -y install nginx"
		]
    }

    lifecycle{
        create_before_destroy = true
    }

}

resource "digitalocean_certificate" "dev" {
    name = "${var.name}-certificate"

    type = "lets_encrypt"

    domains = ["sandevtopper.live"]

    lifecycle{
        create_before_destroy = true
    }
  
}

resource "digitalocean_loadbalancer" "dev" {
    name = "dev-${var.region}"
    region = var.region
    droplet_ids = digitalocean_droplet.dev.*.id

    vpc_uuid = digitalocean_vpc.dev.id

    redirect_http_to_https = true

    forwarding_rule {
        entry_port = 443
        entry_protocol ="https"

        target_port = 80
        target_protocol = "http"


        certificate_id = digitalocean_certificate.dev.id
    }

    forwarding_rule {
        entry_port = 80
        entry_protocol = "http"

        target_port = 80
        target_protocol = "http"

        certificate_id = digitalocean_certificate.dev.id
    }

    lifecycle{
        create_before_destroy = true
    }
}

resource "digitalocean_firewall" "dev" {
   
    name = "dev-only-vpc-traffic"

    droplet_ids = digitalocean_droplet.dev.*.id

    inbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.dev.ip_range]
    }

    inbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.dev.ip_range]
    }

    inbound_rule {
        protocol = "icmp"
        source_addresses = [digitalocean_vpc.dev.ip_range]
    }

    outbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.dev.ip_range]
    }

    outbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.dev.ip_range]
    }

    outbound_rule {
        protocol = "icmp"
        destination_addresses = [digitalocean_vpc.dev.ip_range]
    }

    outbound_rule {
        protocol = "udp"
        port_range = "53"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol = "tcp"
        port_range = "80"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol = "tcp"
        port_range = "443"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol              = "icmp"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
}
