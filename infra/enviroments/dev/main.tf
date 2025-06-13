terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Configuración de servicios
locals {
  environment = "dev"
  
  microservices = [
    { name = "auth-service",      port = 8001, image = "gcr.io/${var.project_id}/auth:latest" },
    { name = "orders-service",    port = 8002, image = "gcr.io/${var.project_id}/orders:latest" },
    { name = "products-service",  port = 8003, image = "gcr.io/${var.project_id}/products:latest" },
    { name = "users-service",     port = 8004, image = "gcr.io/${var.project_id}/users:latest" },
    { name = "inventory-service", port = 8005, image = "gcr.io/${var.project_id}/inventory:latest" },
    { name = "payment-service",   port = 8006, image = "gcr.io/${var.project_id}/payment:latest" },
    { name = "shipping-service",  port = 8007, image = "gcr.io/${var.project_id}/shipping:latest" },
    { name = "analytics-service", port = 8008, image = "gcr.io/${var.project_id}/analytics:latest" },
    { name = "notification-service", port = 8009, image = "gcr.io/${var.project_id}/notification:latest" },
    { name = "gateway-service",   port = 8010, image = "gcr.io/${var.project_id}/gateway:latest" },
  ]
}

# Generate random password for VM access
resource "random_password" "vm_password" {
  length  = 16
  special = true
}

module "network" {
  source       = "../../modules/network"
  network_name = "${local.environment}-vpc"
  subnet_cidr  = var.subnet_cidr
  region       = var.region
  
  ssh_source_ranges = var.ssh_allowed_ips
  microservice_ports = [for svc in local.microservices : tostring(svc.port)]
}

module "microservices_vm" {
  source = "../../modules/microservice-vm"
  
  instance_name        = "${local.environment}-microservices-vm"
  machine_type         = var.vm_machine_type
  zone                 = var.zone
  disk_size_gb         = var.vm_disk_size
  
  network_id           = module.network.network_id
  subnet_id            = module.network.subnet_id
  
  vm_username          = var.vm_username
  vm_password          = random_password.vm_password.result
  
  microservices        = local.microservices
  
  labels = {
    environment = local.environment
    project     = "microservices"
    managed-by  = "terraform"
  }
}