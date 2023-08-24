# Enables Firebase services for the new project created in `main.tf`.
resource "google_firebase_project" "firebase-zebra-docs" {
  provider = google-beta
  project  = "zfnd-prod-zebra"

  # Waits for the required APIs to be enabled.
  depends_on = [
    module.projects.services
  ]
}

resource "google_firebase_web_app" "zebra-book" {
  provider        = google-beta
  project         = "zfnd-prod-zebra"
  display_name    = "Zebra Book"
  deletion_policy = "DELETE"

  depends_on = [google_firebase_project.firebase-zebra-docs]
}

resource "google_firebase_hosting_site" "zebra-book" {
  provider = google-beta
  project  = "zfnd-prod-zebra"
  site_id  = "zebra-docs-book"
  app_id   = google_firebase_web_app.zebra-book.app_id
}

resource "google_firebase_web_app" "zebra-docs-internal" {
  provider        = google-beta
  project         = "zfnd-prod-zebra"
  display_name    = "Zebra Docs - Internal"
  deletion_policy = "DELETE"

  depends_on = [google_firebase_project.firebase-zebra-docs]
}

resource "google_firebase_hosting_site" "zebra-docs-internal" {
  provider = google-beta
  project  = "zfnd-prod-zebra"
  site_id  = "zebra-docs-internal"
  app_id   = google_firebase_web_app.zebra-docs-internal.app_id
}

resource "google_firebase_web_app" "zebra-docs-external" {
  provider        = google-beta
  project         = "zfnd-prod-zebra"
  display_name    = "Zebra Docs - External"
  deletion_policy = "DELETE"

  depends_on = [google_firebase_project.firebase-zebra-docs]
}

resource "google_firebase_hosting_site" "zebra-docs-external" {
  provider = google-beta
  project  = "zfnd-prod-zebra"
  site_id  = "zebra-docs-external"
  app_id   = google_firebase_web_app.zebra-docs-external.app_id
}
