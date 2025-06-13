output "instance_id" {
  value = google_compute_instance.microservices_vm.id
}

output "instance_name" {
  value = google_compute_instance.microservices_vm.name
}

output "external_ip" {
  value = google_compute_instance.microservices_vm.network_interface[0].access_config[0].nat_ip
}

output "internal_ip" {
  value = google_compute_instance.microservices_vm.network_interface[0].network_ip
}

output "ssh_command" {
  value = "ssh -i ${var.ssh_public_key_path} ${var.ssh_user}@${google_compute_instance.microservices_vm.network_interface[0].access_config[0].nat_ip}"
}