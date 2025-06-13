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
  default     = "us-central1-b"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR block"
  default     = "10.1.0.0/24"
}

variable "vm_username" {
  type        = string
  description = "VM username for password authentication"
  default     = "stageuser"
}

variable "ssh_allowed_ips" {
  type        = list(string)
  description = "IPs allowed to access VM"
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
  default     = 120
}