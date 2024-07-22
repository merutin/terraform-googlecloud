provider "google" {
  project     = "delta-playground-404301"
  region      = "us-central1"
  credentials = "./credentials.json"
}

module "cloudrun2" {
  source = "./modules/cloudrun2"
}