# Region to which the Droplet will be deployed
region = "nyc3"
# Name of Digital Ocean Droplet
name = "Paranoid-GHIDRA"
# Size of Droplet (ghidra recommends 4GB of RAM)
size = "s-2vcpu-4gb"
# Resolution of VNC session
resolution = "3440x1440"
# Optionally used to restrict SSH access to Droplet
source_addr = ["0.0.0.0/0", "::/0"]
