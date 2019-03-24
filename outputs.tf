output "vnc_pass" {
    value = "${random_string.password.result}"
}

output "do_ip" {
    value = "${digitalocean_droplet.ghidra.ipv4_address}"
}

output "ssh_key" {
    value = "${path.root}/${var.ssh_key_path}/do_ghidra"
}

output "ssh_config" {
    value = "${path.root}/${var.ssh_config_path}/do_ghidra_config"
}

// SSH tunnel the VNC port to your local machine. You'll need to
// install TightVNC Viewer to connect to localhost:5901
output "connect_cmd" {
    value = "ssh -i ${path.root}/${var.ssh_key_path}/${var.ssh_key_name} -L 5901:localhost:5901 root@${digitalocean_droplet.ghidra.ipv4_address} -N \"\""
}