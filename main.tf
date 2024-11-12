resource "google_storage_bucket" "jandj" {
  name = var.name
  location = var.location
  force_destroy = var.force_destroy
  project = var.project_id
  storage_class = var.storage_class
  default_event_based_hold = var.default_event_based_hold
  labels = var.labels
  enable_object_retention = var.enable_object_retention
  requester_pays = var.requester_pays
  rpo = var.rpo
  uniform_bucket_level_access = var.uniform_bucket_level_access
  public_access_prevention = var.public_access_prevention
}
