terraform {
  required_providers {
    opnsense = {
      version = "0.11.0"
      source  = "browningluke/opnsense"
    }
  }
}

provider "opnsense" {
  uri            = "https://192.168.1.1"
  api_key        = var.opnsense_key
  api_secret     = var.opnsense_secret
  allow_insecure = true
}

resource "opnsense_kea_subnet" "k8_subnet" {
  subnet      = var.subnet_ip
  description = var.subnet_desc

  pools = [
    var.subnet_pool
  ]

}

