resource "esxi_guest" "dfirlab-elk" {
  count                 = 1
  guest_name            = "DFIRLab-${count.index + 1}-elk"
  notes                 = "Contact : me"
  disk_store            = var.datastore
  boot_disk_type        = "thin"
  memsize               = "6048"
  numvcpus              = "4"
  power                 = "on"
  guest_startup_timeout = "180"
  ovf_source            = "../packer/ova/template-Debian10--elk.ova"

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
      "echo 'auto eth1' | sudo tee -a /etc/network/interfaces",
      "echo 'iface eth1 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.11' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ifup eth1",
      "echo 'up route add -net 10.8.0.0/24 gw 10.1.1.254 dev eth1' | sudo tee -a /etc/network/interfaces",
      "( sudo crontab -l; echo \"@reboot sleep 30 && cd /opt/docker-elk; sudo -u elk docker-compose up -d 1>/dev/null 2>&1\" ) | sudo crontab  -",
      "cd /opt/timesketch/; sudo -u elk docker-compose exec timesketch-web tsctl add_user -u analyste -p analyste",
      "sudo shutdown -r +1"
    ]
  }
}
