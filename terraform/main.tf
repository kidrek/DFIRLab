terraform {
  required_version = ">= 0.12"
}

provider "esxi" {
  esxi_hostname = "<esxi_host>"
  esxi_hostport = "<esxi_ssh_port>"
  esxi_username = "<esxi_username>"
  esxi_password = "<esxi_password>"
}
