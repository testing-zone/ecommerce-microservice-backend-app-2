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
  default     = "us-central1-c"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR block"
  default     = "10.2.0.0/24"
}

variable "vm_username" {
  type        = string
  description = "VM username for password authentication"
  default     = "produser"
}

variable "ssh_allowed_ips" {
  type        = list(string)
  description = "IPs allowed to access VM (should be restricted in production)"
  default     = ["0.0.0.0/0"]  # Change this to specific IPs in production
}

variable "vm_machine_type" {
  type        = string
  description = "VM machine type"
  default     = "e2-standard-8"  # Larger for production
}

variable "vm_disk_size" {
  type        = number
  description = "VM disk size in GB"
  default     = 200  # Larger disk for production
}