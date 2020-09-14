resource "esxi_guest" "dfirlab-vpn" {
  count                 = 1
  guest_name            = "DFIRLab-${count.index + 1}-vpn"
  notes                 = "Contact : me"
  disk_store            = var.datastore
  boot_disk_type        = "thin"
  memsize               = "1024"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"
  ovf_source            = "../packer/ova/template-Debian10.ova"

  # Network configuration
  network_interfaces {
    virtual_network     = var.network-portgroup-deployment
    nic_type            = "e1000"
  }

  network_interfaces {
    virtual_network     = "DFIRLab-${count.index + 1}-vm"
    nic_type            = "e1000"
  }


  # Connection used to apply some modifications on system
  connection {
    host                = self.ip_address
    type                = "ssh"
    user                = "analyste"
    private_key         = file("../packer/FILES/analyste.key")
    timeout             = "180s"
  }

  ## Command executed on remote VM through SSH connection
  provisioner "remote-exec" {
    inline = [
      "echo 'dfirlab-vpn' | sudo tee /etc/hostname",
      "echo '127.0.0.1    dfirlab-vpn' | sudo tee /etc/hosts",
      "sudo apt update; sudo apt install -y openvpn curl",
      "curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh; chmod +x openvpn-install.sh",
      "sudo AUTO_INSTALL=y APPROVE_INSTALL=y ENDPOINT=\"<server_ip>\" IPV6_SUPPORT=n PORT_CHOICE=1 CLIENT=analyste DNS=1 ./openvpn-install.sh",
      "echo 'push \"route 10.1.1.0 255.255.255.0\"' | sudo tee -a /etc/openvpn/server.conf",
      "echo 'auto eth1' | sudo tee -a /etc/network/interfaces",
      "echo 'iface eth1 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.254' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ifup eth1"
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../packer/FILES/analyste.key analyste@${self.ip_address}:/home/analyste/analyste.ovpn ../packer/FILES/analyste.ovpn; ../slack-uploadfile.sh ../packer/FILES/analyste.ovpn \"Configuration Openvpn\"; ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../packer/FILES/analyste.key -t analyste@${self.ip_address} 'sudo reboot'"
  }
}
