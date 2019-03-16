variable "image" {
    type = "string"
    default = "ubuntu-18-04-x64"
}
variable "region" {
    type = "string"
    default = "nyc3"
}
variable "size" {
    type = "string"
    default = "s-2vcpu-2gb"
}
variable "name" {
    type = "string"
    default = "Paranoid-GHIDRA"
}

variable "resolution" {
    type = "string"
    default = "3440x1440"
}

variable "source_addr" {
    type = "list"
    default = ["0.0.0.0/0", "::/0"]
}

variable "ssh_key_name" {
    type = "string"
    default = "do_ghidra"
}
variable "ssh_key_path" {
    type = "string"
    default = "./data/ssh_keys"
}

variable "ssh_config_path" {
    type = "string"
    default = "./data/ssh_configs"
}

variable "template_path" {
    type = "string"
    default = "./data/templates"
}

variable "chmod_command" {
  type        = "string"
  default     = "chmod 600 %v"
}

variable "do_ssh_key_name" {
  type        = "string"
  default     = "Paranoid-GHIDRA-Key"
}

variable "do_firewall_name" {
  type        = "string"
  default     = "Paranoid-GHIDRA-Firewall"
}