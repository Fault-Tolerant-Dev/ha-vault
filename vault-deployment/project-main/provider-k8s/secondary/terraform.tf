terraform {
  required_version = "= 0.11.10"

  backend "gcs" {
    prefix      = "tfstate-secondary"
    credentials = "k8s_state.key.json"
    bucket      = "k8s-state-38109"
  }
}

provider "kubernetes" {}

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

provider "template" {
  # version = "~> 1.4"
}

provider "local" {
  # version = "~> 1.4"
}
