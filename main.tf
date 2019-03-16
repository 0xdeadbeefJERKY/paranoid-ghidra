provider "digitalocean" {}

locals {
    private_key_name = "${var.ssh_key_path}/${var.ssh_key_name}"
    ssh_config_name = "${var.ssh_config_path}/${var.ssh_key_name}_config"
}

resource "random_string" "password" {
  length = 8
  special = false
  min_lower = 1
  min_upper = 1
  min_numeric = 1
}

resource "tls_private_key" "gkey" {
    algorithm = "RSA"
    rsa_bits = "4096"
}

resource "local_file" "private_key" {
    content = "${tls_private_key.gkey.private_key_pem}"
    filename = "${local.private_key_name}"
}

resource "null_resource" "chmod" {
    depends_on = ["local_file.private_key"]

    triggers {
        local_file_private_key = "local_file.private_key"
    }

    provisioner "local-exec" {
        command = "${format(var.chmod_command, "${local.private_key_name}")}"
    }
}

resource "local_file" "public_key" {
    content = "${tls_private_key.gkey.public_key_openssh}"
    filename = "${local.private_key_name}.pub"
}

resource "local_file" "ssh_config" {
    content = "${data.template_file.ssh_config.rendered}"
    filename = "${local.ssh_config_name}"
}

resource "digitalocean_ssh_key" "dokey" {
    name = "${var.do_ssh_key_name}"
    public_key = "${tls_private_key.gkey.public_key_openssh}"
}

resource "digitalocean_droplet" "ghidra" {
    name = "${var.name}"
    image = "${var.image}"
    size = "${var.size}"
    region = "${var.region}"
    ssh_keys = ["${digitalocean_ssh_key.dokey.id}"]
    private_networking = true
    backups = false
    ipv6 = true

    // sleep for 3 minutes to allow for Droplet to fully initialize
    // before executing bootstrap script
    provisioner "local-exec" {
        command = "sleep 180"
    }

    provisioner "file" {
        content = "${data.template_file.bootstrap.rendered}"
        destination = "/tmp/bootstrap.sh"

        connection {
            type = "ssh"
            private_key = "${tls_private_key.gkey.private_key_pem}"
            user = "root"
            timeout = "5m"
        }
    }
    
    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/bootstrap.sh",
            #"sed -i 's/\r$//g' /tmp/bootstrap.sh",
            "/tmp/bootstrap.sh",
        ]
        connection {
            type = "ssh"
            private_key = "${tls_private_key.gkey.private_key_pem}"
            user = "root"
            timeout = "5m"
        }
    }
}

resource "digitalocean_firewall" "firewall" {
    name = "${var.do_firewall_name}"
    droplet_ids = ["${digitalocean_droplet.ghidra.id}"]
    inbound_rule = [
        {
            protocol = "tcp"
            port_range = "22"
            source_addresses = "${var.source_addr}"
        },
    ]
    outbound_rule = [
        {
            protocol = "tcp"
            port_range = "1-65535"
            destination_addresses = ["0.0.0.0/0", "::/0"]
        },
         {
            protocol = "udp"
            port_range = "1-65535"
            destination_addresses = ["0.0.0.0/0", "::/0"]
        },
    ]
}

data "template_file" "ssh_config" {
  template = "${file("${var.template_path}/ssh_config.tpl")}"

  vars {
    name = "do_ghidra"
    hostname = "${digitalocean_droplet.ghidra.ipv4_address}"
    user = "root"
    identityfile = "${local.private_key_name}"
  }

}

data "template_file" "bootstrap" {
    template = "${file("${var.template_path}/bootstrap.tpl")}"
    
    vars {
        vnc_pass = "${random_string.password.result}"
        resolution = "${var.resolution}"
    }
}

resource "null_resource" "gen_ssh_config" {
  triggers {
    template_rendered = "${data.template_file.ssh_config.rendered}"
  }
}


