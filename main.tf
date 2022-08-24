# Required Google APIs

locals {
  googleapis = ["bigtable.googleapis.com", "cloudkms.googleapis.com", ]
}

resource "google_project_service" "bigtable" {
  for_each           = toset(local.googleapis)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_kms_key_ring" "example-keyring650" {
  name     = "keyring-example650"
  location = "us-central1"
  depends_on = [
    google_project_service.bigtable
  ]
}

resource "google_kms_crypto_key" "bt_key650" {
  name     = "key650"
  key_ring = google_kms_key_ring.example-keyring650.id
}

resource "google_kms_key_ring" "example-keyring651" {
  name     = "keyring-example651"
  location = "us-east1"
  depends_on = [
    google_project_service.bigtable
  ]
}

resource "google_kms_crypto_key" "bt_key651" {
  name     = "key651"
  key_ring = google_kms_key_ring.example-keyring651.id
}


# Deployment to PROD need to have HA support deploying cluster in different zones of regions.

resource "google_bigtable_instance" "bt_prod_instance650" {
  name                = "bt-wf-instance650"
  deletion_protection = false

  cluster {
    cluster_id   = "bt-instance-cluster-central"
    storage_type = "HDD"
    zone         = "us-central1-b"
    kms_key_name = google_kms_crypto_key.bt_key650.id
    autoscaling_config {
      min_nodes  = 1
      max_nodes  = 5
      cpu_target = 50
    }
  }

  cluster {
    cluster_id   = "bt-instance-cluster-east"
    storage_type = "HDD"
    zone         = "us-east1-b"
    kms_key_name = google_kms_crypto_key.bt_key651.id
    autoscaling_config {
      min_nodes  = 1
      max_nodes  = 5
      cpu_target = 50
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_bigtable_instance" "bt_prod_instance651" {
  name                = "bt-wf-instance651"
  deletion_protection = false

  cluster {
    cluster_id   = "bt-instance-cluster-central-b"
    storage_type = "HDD"
    zone         = "us-central1-b"
    kms_key_name = google_kms_crypto_key.bt_key650.id
    autoscaling_config {
      min_nodes  = 1
      max_nodes  = 5
      cpu_target = 50
    }
  }

  cluster {
    cluster_id   = "bt-instance-cluster-central-a"
    storage_type = "HDD"
    zone         = "us-central1-a"
    kms_key_name = google_kms_crypto_key.bt_key650.id
    autoscaling_config {
      min_nodes  = 1
      max_nodes  = 5
      cpu_target = 50
    }
  }
}
 