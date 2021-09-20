terraform {
  required_version = "= 0.11.10"


  backend "gcs" {
    prefix      = "tfstate"
    credentials = "tf_project.key.json"
    bucket      = "project-state-1234"
  }
}

provider "google" {
  credentials = "${file("tf_project.key.json")}"
  project     = "${var.project_id}"
  version     = "~> 2.19.0"
}

provider "google-beta" {
  credentials = "${file("tf_project.key.json")}"
  project     = "${var.project_id}"
  version     = "~> 2.19.0"
}


provider "external" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1.2"
}

provider "random" {
  version = "~> 2.2.1"
}

provider "tls" {
  version = "~> 2.1.1"
}
