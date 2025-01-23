provider "google" {
  project     = "delta-playground-404301"
  region      = "us-central1"
  credentials = "./credentials.json"
}

# module "cloudrun2" {
#   source = "./modules/cloudrun2"
# }

# module "cloudsql" {
#   source = "./modules/cloudsql"
# }

# module "artifact-registry" {
#   source = "./modules/artifact-registry"
# }
# resource "google_artifact_registry_repository" "sample2" {
#   format                 = "DOCKER"
#   repository_id          = "mock-segment-filter"
#   location = "asia-northeast1"
# }

# import {
#   id = "projects/{{project}}/locations/asia-northeast1/repositories/{{repository_id}}"
#   to = google_artifact_registry_repository.sample2
# }

module "buckets" {
  source = "./modules/loop"

  buckets = {
    "bucket1" = {
      region = "us-central1"
    },
    "bucket2" = {
      region = "asia-northeast1",
      age   = 30
      lifecycle_rule = {
        age = 60
      }
    },
  }
}