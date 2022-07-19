variable "project_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "builder_sa" {
  type = string
}

source "googlecompute" "test-image" {
  project_id                  = var.project_id
  source_image_family         = "ubuntu-2004"
  zone                        = var.zone
  image_description           = "Nextcloud"
  ssh_username                = "root"
  tags                        = ["nextcloud-aio"]
  impersonate_service_account = var.builder_sa
}

build {
  sources = ["sources.googlecompute.test-image"]
}
