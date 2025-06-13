variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP Zone"
  default     = "us-central1-a"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR block"
  default     = "10.0.0.0/24"
}

variable "ssh_user" {
  type        = string
  description = "SSH username"
  default     = "terraform-user"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key"
}

variable "ssh_allowed_ips" {
  type        = list(string)
  description = "IPs allowed to SSH (usar tu IP para mayor seguridad)"
  default     = ["0.0.0.0/0"]
}

variable "vm_machine_type" {
  type        = string
  description = "VM machine type"
  default     = "e2-standard-4"
}

variable "vm_disk_size" {
  type        = number
  description = "VM disk size in GB"
  default     = 100
}