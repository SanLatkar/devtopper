resource "digitalocean_droplet" "web2" {
	image = "ubuntu-16-04-x64"
	name = "web2"
	region = "fra1"
	size = "s-1vcpu-1gb"
	private_networking = true
	ssh_keys = [
		var.ssh_fingerprint
	]
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

}