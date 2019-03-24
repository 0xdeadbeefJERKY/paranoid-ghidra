provider "digitalocean" {}

locals {
    # Full path to file in which private key will be stored
    private_key_name = "${var.ssh_key_path}/${var.ssh_key_name}"
    # Full path to file in which SSH config will be stored
    ssh_config_name = "${var.ssh_config_path}/${var.ssh_key_name}_config"
}

# Generate VNC password (capped at 8 characters)
resource "random_string" "password" {
  length = 8
  special = false
  min_lower = 1
  min_upper = 1
  min_numeric = 1
}

# Generate SSH keypair
resource "tls_private_key" "gkey" {
    algorithm = "RSA"
    rsa_bits = "4096"
}

# Store private key locally
resource "local_file" "private_key" {
    content = "${tls_private_key.gkey.private_key_pem}"
    filename = "${local.private_key_name}"
}

# Correct private key permissions
resource "null_resource" "chmod" {
    depends_on = ["local_file.private_key"]

    triggers {
        local_file_private_key = "local_file.private_key"
    }

    provisioner "local-exec" {
        command = "${format(var.chmod_command, "${local.private_key_name}")}"
    }
}

# Store public key locally
resource "local_file" "public_key" {
    content = "${tls_private_key.gkey.public_key_openssh}"
    filename = "${local.private_key_name}.pub"
}

# Generate SSH config file 
resource "local_file" "ssh_config" {
    content = "${data.template_file.ssh_config.rendered}"
    filename = "${local.ssh_config_name}"
}

# Add public key to Digital Ocean
resource "digitalocean_ssh_key" "dokey" {
    name = "${var.name}-Key"
    public_key = "${tls_private_key.gkey.public_key_openssh}"
}

# Create Droplet
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

    # Render bootstrap script with provided variables/input
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
    
    # Execute bootstrap script on Droplet
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

# Create cloud firewall in Digital Ocean and add Droplet
resource "digitalocean_firewall" "firewall" {
    name = "${var.name}-Firewall"
    droplet_ids = ["${digitalocean_droplet.ghidra.id}"]
    inbound_rule = [
        {
            # Only allow inbound SSH traffic from whitelisted IP(s)
            # This will default to 0.0.0.0, ::/0 
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

# SSH config file template
data "template_file" "ssh_config" {
  template = "${file("${var.template_path}/ssh_config.tpl")}"

  vars {
    name = "do_ghidra"
    hostname = "${digitalocean_droplet.ghidra.ipv4_address}"
    user = "root"
    identityfile = "${local.private_key_name}"
  }

}

# Bootstrap script template
data "template_file" "bootstrap" {
    template = "${file("${var.template_path}/bootstrap.tpl")}"
    
    vars {
        vnc_pass = "${random_string.password.result}"
        resolution = "${var.resolution}"
        # Determine which apt packages to install based on
        # chosen desktop evnironment (GNOME or xfce4)
        desktop_packages = "${var.desktop == "GNOME" ? var.gnome_packages : var.xfce4_packages}"
        mode = "${var.desktop}"
    }
}

/*
resource "null_resource" "gen_ssh_config" {
  triggers {
    template_rendered = "${data.template_file.ssh_config.rendered}"
  }
}
*/