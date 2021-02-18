resource "digitalocean_database_cluster" "postgres-cluster" {

    name       = "${var.name}-database-cluster"

    engine     = "pg"

    version    = "11"

    size       = var.database_size

    region     = var.region

    node_count = var.db_count

    private_network_uuid = digitalocean_vpc.dev.id
}

resource "digitalocean_database_firewall" "postgress-cluster-firewall" {
    
    cluster_id = digitalocean_database_cluster.postgres-cluster.id

    rule {
        type = "tag"
        value = "${var.name}-webserver"
    }
}