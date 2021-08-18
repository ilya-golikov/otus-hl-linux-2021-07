
output "iscsi_node_ext_ip" {
  value = yandex_compute_instance.iscsi-node[*].network_interface.0.nat_ip_address

}

output "gfs2_nodes_ext_ip" {
  value = yandex_compute_instance.gfs2-node[*].network_interface.0.nat_ip_address
}

resource "local_file" "AnsibleInventory" {
  content = templatefile("inventory.tmpl",
    {
      iscsi_node_ip = yandex_compute_instance.iscsi-node.network_interface.0.nat_ip_address,
      iscsi_int_ip  = yandex_compute_instance.iscsi-node.network_interface.0.ip_address,
      gfs2_nodes_ip = yandex_compute_instance.gfs2-node[*].network_interface.0.nat_ip_address,
      gfs2_int_ip   = yandex_compute_instance.gfs2-node[*].network_interface.0.ip_address,
    }
  )
  filename             = "./inventory"
  directory_permission = "0755"
  file_permission      = "0644"
}

output "Message" {
  value = "Run ansible-playbook playbooks/provision.yml"
}
