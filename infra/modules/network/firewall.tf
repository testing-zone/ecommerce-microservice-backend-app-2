resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["ssh-enabled"]
  
  description = "Allow SSH access to instances with ssh-enabled tag"
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.network_name}-allow-http-https"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
  
  description = "Allow HTTP and HTTPS traffic"
}

resource "google_compute_firewall" "allow_microservices" {
  name    = "${var.network_name}-allow-microservices"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = var.microservice_ports
  }

  source_ranges = var.microservice_source_ranges
  target_tags   = ["microservices"]
  
  description = "Allow access to microservice ports"
}