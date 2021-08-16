provider "yandex" {
    service_account_key_file = pathexpand(var.service_account_key_file)
    cloud_id = var.cloud_id
    folder_id = var.folder_id
}

resource "yandex_vpc_network"  "default" {
    name = "network-1"
}

resource "yandex_vpc_subnet" "subnet-a" {
    v4_cidr_blocks = ["10.10.50.0/24"]
    zone           = "ru-central1-a"
    name = "subnet-a"
    network_id     = yandex_vpc_network.default.id
}

resource "yandex_compute_instance" "node-1" {
    name  = "nginx-node"
    zone = "ru-central1-a"
    resources {
        cores  = 2
        memory = 4
    }

    boot_disk {
        initialize_params {
            image_id = var.image_id
            size = 10
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
        host        = yandex_compute_instance.node-1.network_interface.0.nat_ip_address
    }

    provisioner "remote-exec" {
        inline = ["echo 'Im ready!'"]

    }

    provisioner "local-exec" {
        command = "ansible-playbook -i '${self.network_interface.0.nat_ip_address},' --private-key ~/.ssh/id_rsa provision.yml"
    }
}
