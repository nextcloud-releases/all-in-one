packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "nextcloud-aio"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "nextcloud-aio"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    inline = ["curl -fsSL https://raw.githubusercontent.com/nextcloud-releases/all-in-one/main/.build/ova/build.sh | sed 's|sudo||' | bash"]
  }
}