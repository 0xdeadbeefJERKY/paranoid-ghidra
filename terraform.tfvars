# Region to which the Droplet will be deployed
region = "nyc3"
# Name of Digital Ocean Droplet
name = "Paranoid-GHIDRA"
# Size of Droplet (defaults to 4GB of RAM as per the
# recommendation in ghidra's documentation)
size = "s-2vcpu-4gb"
# Specify resolution of VNC session (default is 1920x1080)
resolution = "1920x1080"
# Optionally used to restrict SSH access to Droplet
#source_addr = ["0.0.0.0/0", "::/0"]
# Choose your desktop environment. Supported values are
# GNOME and xfce4 
desktop = "GNOME"
