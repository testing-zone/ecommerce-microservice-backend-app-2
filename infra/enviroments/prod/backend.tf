terraform {
  backend "gcs" {
    bucket = "terraform-bucket-ingesoft"
    prefix = "prod/terraform.tfstate"
  }
}