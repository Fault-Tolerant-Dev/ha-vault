terraform {
  required_version = "= 0.11.10"

 backend "gcs" {
   prefix      = "tfstate"
   credentials = "vault_state.key.json"
   bucket      = "vault-state-4630"
 }
}

provider "vault" {
  address = "https://vault.evilmachine.net:8200"
  token = "s.DfunoS2uC3Qi5aoUKnOAL0Kq"
  skip_tls_verify = true
}

provider "external" {
  version = "~> 1.0"
}

provider "null" {
  version = "~> 2.0"
}

provider "random" {
  version = "~> 2.0"
}

provider "tls" {
  version = "~> 1.2"
}