output "vm_external_ip" {
  value       = module.microservices_vm.external_ip
  description = "External IP of the microservices VM"
}

output "vm_internal_ip" {
  value       = module.microservices_vm.internal_ip
  description = "Internal IP of the microservices VM"
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/terraform-keys/terraform-key ${var.ssh_user}@${module.microservices_vm.external_ip}"
  description = "SSH command to connect to the VM"
}

output "service_urls" {
  value = {
    for svc in local.microservices : svc.name => "http://${module.microservices_vm.external_ip}:${svc.port}"
  }
  description = "URLs for all microservices"
}

output "nginx_url" {
  value       = "http://${module.microservices_vm.external_ip}"
  description = "URL for Nginx reverse proxy"
}