variable "instance_name" {
  type        = string
  description = "Name of the VM instance"
}

variable "machine_type" {
  type        = string
  description = "Machine type for the VM"
  default     = "e2-standard-4"
}

variable "zone" {
  type        = string
  description = "Zone where the VM will be created"
}

variable "image" {
  type        = string
  description = "Boot disk image"
  default     = "debian-cloud/debian-12"
}

variable "disk_size_gb" {
  type        = number
  description = "Boot disk size in GB"
  default     = 100
}

variable "disk_type" {
  type        = string
  description = "Boot disk type"
  default     = "pd-ssd"
}

variable "network_id" {
  type        = string
  description = "Network ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "vm_username" {
  type        = string
  description = "VM username for password authentication"
  default     = "vmuser"
}

variable "vm_password" {
  type        = string
  description = "VM password for authentication"
  sensitive   = true
}

variable "network_tags" {
  type        = list(string)
  description = "Network tags for firewall rules"
  default     = ["ssh-enabled", "http-server", "https-server", "microservices", "rdp-enabled"]
}

variable "labels" {
  type        = map(string)
  description = "Labels for the VM"
  default     = {}
}

variable "service_account_email" {
  type        = string
  description = "Service account email"
  default     = null
}

variable "service_account_scopes" {
  type        = list(string)
  description = "Service account scopes"
  default     = ["cloud-platform"]
}

variable "microservices" {
  type = list(object({
    name  = string
    port  = number
    image = string
  }))
  description = "List of microservices to deploy"
}