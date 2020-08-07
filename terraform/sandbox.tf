resource "esxi_guest" "pin-sandbox" {
  count                 = 1
  guest_name            = "PIN-${count.index + 1}-Sandbox"
  notes                 = "Contact : me"
  disk_store            = "datastore1"
  boot_disk_type        = "thin"
  #boot_disk_size        = "100"
  memsize               = "2048"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"

  ovf_source = "../ovf-template/debian.ova"

  network_interfaces {
    virtual_network = "Terraform-deployment"
    nic_type        = "e1000"
  }

  network_interfaces {
    virtual_network = "pin-${count.index + 1}-vm"
    nic_type        = "e1000"
  }

  connection {
    host        = self.ip_address
    type        = "ssh"
    user        = "ansible"
    private_key = file("./ansible-key")
    timeout     = "180s"
  }

  ## Command executed on remote VM through SSH connection
  provisioner "remote-exec" {
    inline = [
      "echo 'Sandbox' | sudo tee /etc/hostname",
      "sudo apt update; sudo apt install -y git-core",
      "git clone https://github.com/kidrek/cuckoo.git",
      "sudo -u ansible -- sh -c 'cd /home/ansible/cuckoo; chmod +x cuckoo_install_kvm.sh; ./cuckoo_install_kvm.sh; ./cuckoo_install_kvm.sh'",
      "echo '127.0.0.1    Sandbox' | sudo tee /etc/hosts",
      "echo 'auto ens37' | sudo tee -a /etc/network/interfaces",
      "echo 'iface ens37 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.14' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ifup ens37",
      "sudo reboot",
    ]
  }
}
