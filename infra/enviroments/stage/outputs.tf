output "vm_external_ip" {
  value       = module.microservices_vm.external_ip
  description = "External IP of the microservices VM"
}

output "vm_internal_ip" {
  value       = module.microservices_vm.internal_ip
  description = "Internal IP of the microservices VM"
}

output "vm_username" {
  value       = var.vm_username
  description = "Username for VM access"
}

output "vm_password" {
  value       = random_password.vm_password.result
  description = "Password for VM access"
  sensitive   = true
}

output "ssh_command" {
  value       = "ssh ${var.vm_username}@${module.microservices_vm.external_ip}"
  description = "SSH command to connect to the Linux VM using password"
}

output "service_urls" {
  value = {
    for svc in local.microservices : svc.name => "http://${module.microservices_vm.external_ip}:${svc.port}"
  }
  description = "URLs for all microservices"
}