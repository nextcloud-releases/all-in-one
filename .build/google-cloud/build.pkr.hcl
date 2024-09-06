variable "project_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "builder_sa" {
  type = string
}

source "googlecompute" "nextcloud-aio" {
  project_id                  = var.project_id
  source_image_family         = "ubuntu-2404-lts"
  zone                        = var.zone
  image_description           = "Nextcloud AIO"
  ssh_username                = "root"
  tags                        = ["nextcloud"]
  impersonate_service_account = var.builder_sa
  temporary_key_pair_type = "ed25519"
}

build {
  sources = ["sources.googlecompute.nextcloud-aio"]
  provisioner "shell" {
    inline = ["curl -fsSL https://raw.githubusercontent.com/nextcloud-releases/all-in-one/main/.build/ova/build.sh | sed 's|sudo||' | bash"]
  }
}
