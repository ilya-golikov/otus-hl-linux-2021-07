output "Nginx_instance_address" {
  value = "http://${yandex_compute_instance.node-1.network_interface.0.nat_ip_address}/"
}
