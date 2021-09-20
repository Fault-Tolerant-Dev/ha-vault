terraform {
  required_version = "= 0.11.10"

  backend "gcs" {
    prefix      = "tfstate-runtime"
   credentials = "vault_state.key.json"
   bucket      = "vault-state-4630"
  }
}

provider "vault" {
  address = "https://vault.evilmachine.net:8200"
  token = "s.RbODfgPghMv2G9VsdlM0YHN8"


  skip_tls_verify = true
  version     = "~> 2.5.0"
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



