provider "yandex" {
  service_account_key_file = pathexpand(var.service_account_key_file)
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}

resource "yandex_vpc_network" "default" {
  name = "network-1"
}

resource "yandex_vpc_subnet" "subnet-a" {
  v4_cidr_blocks = ["10.10.50.0/24"]
  zone           = "ru-central1-a"
  name           = "subnet-a"
  network_id     = yandex_vpc_network.default.id
}

resource "yandex_compute_disk" "disk-1" {
  name = "empty-disk"
  type = "network-hdd"
  zone = "ru-central1-a"
  size = "10"
}

resource "yandex_compute_instance" "iscsi-node" {
  name = "iscsi-node"
  zone = "ru-central1-a"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = "100"
  }

  platform_id = "standard-v2"

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
    }
  }
  secondary_disk {
    disk_id = yandex_compute_disk.disk-1.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = yandex_compute_instance.iscsi-node.network_interface.0.nat_ip_address
  }
  provisioner "remote-exec" {
    inline = ["echo connection-ready"]
  }
}
resource "yandex_compute_instance" "gfs2-node" {
  name  = "gfs2-node-${count.index}"
  count = 3
  zone  = "ru-central1-a"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = "100"
  }
  scheduling_policy {
    preemptible = true
  }

  platform_id = "standard-v2"

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }
}
