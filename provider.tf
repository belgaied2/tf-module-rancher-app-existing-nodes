provider "rancher2" {
  api_url = var.api_url
  token_key = var.token_key
}

terraform{
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.15.1"
    }
  }
  required_version = ">= 1.0.0"
}
