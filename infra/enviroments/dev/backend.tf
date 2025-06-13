terraform {
  backend "gcs" {
    bucket = "terraform-bucket-ingesoft"
    prefix = "dev/terraform.tfstate"
  }
}