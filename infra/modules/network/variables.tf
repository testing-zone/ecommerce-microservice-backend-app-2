variable "network_name" {
  type        = string
  description = "Name of the VPC network"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for the subnet"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "ssh_source_ranges" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH"
  default     = ["0.0.0.0/0"]
}

variable "microservice_ports" {
  type        = list(string)
  description = "Ports for microservices"
  default     = ["8001", "8002", "8003", "8004", "8005", "8006", "8007", "8008", "8009", "8010"]
}

variable "microservice_source_ranges" {
  type        = list(string)
  description = "CIDR blocks allowed to access microservices"
  default     = ["0.0.0.0/0"]
}