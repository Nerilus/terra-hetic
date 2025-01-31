provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {}
variable "region" { default = "europe-west3" }
variable "zone" { default = "europe-west3-c" }
variable "second_region" { default = "europe-west1" }
variable "second_zone" { default = "europe-west1-b" }
variable "app_name" { default = "emp-mng" }
variable "bucket_name" { default = "projet-hetic" }

# Création du VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.app_name}-vpc"
  auto_create_subnetworks = false
}

# Création du premier sous-réseau (Allemagne)
resource "google_compute_subnetwork" "subnet_de" {
  name          = "${var.app_name}-${var.region}-subnet"
  network       = google_compute_network.vpc.name
  region        = var.region
  ip_cidr_range = "10.0.0.0/24"
}

#  Création du second sous-réseau (France)
resource "google_compute_subnetwork" "subnet_fr" {
  name          = "${var.app_name}-${var.second_region}-subnet"
  network       = google_compute_network.vpc.name
  region        = var.second_region
  ip_cidr_range = "10.0.1.0/24"
}

#  Création de la règle de pare-feu
resource "google_compute_firewall" "firewall" {
  name    = "${var.app_name}-web-fw"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "5002"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["backend"]
}

#  Création de la première instance Compute Engine (Allemagne)
resource "google_compute_instance" "vm_de" {
  name         = "${var.app_name}-vm-de"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["backend", "http-server"]

  boot_disk {
    initialize_params {
      image = "debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_de.name

    access_config {
      # Ajoute une IP publique
    }
  }

  # metadata_startup_script = "https://storage.googleapis.com/${var.bucket_name}/startup-script.sh"
}

#  Création de la seconde instance Compute Engine (France)
resource "google_compute_instance" "vm_fr" {
  name         = "${var.app_name}-vm-fr"
  machine_type = "e2-medium"
  zone         = var.second_zone

  tags = ["backend", "http-server"]

  boot_disk {
    initialize_params {
      image = "debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_fr.name

    access_config {
     
    }
  }

  # metadata_startup_script = "https://storage.googleapis.com/${var.bucket_name}/startup-script.sh"
}
