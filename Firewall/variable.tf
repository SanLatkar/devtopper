variable "do_token" {}

variable region {
    type = string
    default = "ams3"
}

variable "ssh_fingerprint" {}

variable "subdomain" {
    type = string  
}

variable "domain_name" {
    type = string
}

variable droplet_count {
    type = number
    default = 2  
}

variable "name" {
    type = string
    default = "devtoppers"
}

variable "database_size" {
  type = string
  default = "db-s-1vcpu-1gb"
}

variable "image" {
    type = string
    default = "ubuntu-20-04-x64"  
}

variable "db_count" {
  type = number
  default = 1
}

variable "droplet_size" {
    type = string
    default = "s-1vcpu-1gb"
}