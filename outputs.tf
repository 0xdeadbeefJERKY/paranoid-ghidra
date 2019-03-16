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

// For reasons unknown to me, manually scp'ing and executing the
// bootstrap script on the Droplet works just fine, but when it's
// provisioning via Terraform, the VNC session doesn't give you a
// proper desktop session. These commands allow you to manually
// kill and restart vncserver
output "start_vnc" {
    value = [
        "ssh -i ${path.root}/${var.ssh_key_path}/do_ghidra root@${digitalocean_droplet.ghidra.ipv4_address}",
        "vncserver -kill :1",
        "vncserver -nolisten tcp -localhost -geometry ${var.resolution} :1"
    ]
}

// SSH tunnel the VNC port to your local machine. You'll need to
// install TightVNC Viewer to connect to localhost:5901
output "connect_cmd" {
    value = "ssh -i ${path.root}/${var.ssh_key_path}/do_ghidra -L 5901:localhost:5901 root@${digitalocean_droplet.ghidra.ipv4_address} -N \"\""
}