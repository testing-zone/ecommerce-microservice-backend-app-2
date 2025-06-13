resource "google_compute_instance" "microservices_vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size_gb
      type  = var.disk_type
    }
  }
  network_interface {
    network    = var.network_id
    subnetwork = var.subnet_id
    
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    # Completely disable OS Login to use local users
    enable-oslogin = "FALSE"
    block-project-ssh-keys = "TRUE"
    
    # Configure startup script that sets up user and password
    startup-script = templatefile("${path.module}/startup-password.sh", {
      microservices = var.microservices
      username      = var.vm_username
      password      = var.vm_password
    })
  }

  tags = var.network_tags

  labels = var.labels

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = true
  }

  allow_stopping_for_update = true
}
