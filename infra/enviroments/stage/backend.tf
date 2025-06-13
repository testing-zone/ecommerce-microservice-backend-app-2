terraform {
  backend "gcs" {
    bucket = "terraform-bucket-ingesoft"
    prefix = "stage/terraform.tfstate"
  }
}