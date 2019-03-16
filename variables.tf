variable "image" {
    type = "string"
    default = "ubuntu-18-04-x64"
    description = "OS image to use for Droplet"
}
variable "region" {
    type = "string"
    default = "nyc3"
    description = "Region to which the Droplet will be deployed"
}
variable "size" {
    type = "string"
    default = "s-2vcpu-2gb"
    description = "Droplet size (number of vCPUs and amount of RAM)"
}
variable "name" {
    type = "string"
    default = "Paranoid-GHIDRA"
    description = "Droplet name"
}

variable "resolution" {
    type = "string"
    default = "3440x1440"
    description = "Resolution of VNC desktop session"
}

variable "source_addr" {
    type = "list"
    default = ["0.0.0.0/0", "::/0"]
    description = "IP address to be whitelisted by Digital Ocean firewall for SSH access to Droplet"
}

variable "ssh_key_name" {
    type = "string"
    default = "do_ghidra"
    description = "Name for public/private SSH keys automatically generated"
}
variable "ssh_key_path" {
    type = "string"
    default = "./data/ssh_keys"
    description = "Path in which the SSH keypair will be stored locally"
}

variable "ssh_config_path" {
    type = "string"
    default = "./data/ssh_configs"
    description = "Path in which the SSH config file will be stored locally"
}

variable "template_path" {
    type = "string"
    default = "./data/templates"
    description = "Path in which the various templates can be found"
}

variable "chmod_command" {
  type        = "string"
  default     = "chmod 600 %v"
  description = "chmod command to avoid SSH error regarding open private key file permissions"
}

variable "do_ssh_key_name" {
  type        = "string"
  default     = "Paranoid-GHIDRA-Key"
  description = "Name of SSH key added to Digital Ocean for Droplet access"
}

variable "do_firewall_name" {
  type        = "string"
  default     = "Paranoid-GHIDRA-Firewall"
  description = "Name of Digital Ocean firewall assigned to Droplet"
}