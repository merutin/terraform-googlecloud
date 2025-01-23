resource "google_artifact_registry_repository" "sample" {
  format                 = "DOCKER"
  location               = "asia-northeast1"
  repository_id          = "sample-app"
  cleanup_policy_dry_run = true

  cleanup_policies {
    id     = "keep-20-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count            = 20
    }
  }
}
