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
      "sudo -u analyste -- sh -c 'cd /home/analyste/cuckoo; chmod +x cuckoo_install_kvm.sh; ./cuckoo_install_kvm.sh; ./cuckoo_install_kvm.sh'; sudo -u cuckoo -- sh -c 'sed -i \"s/cuckoo1/win10/\" /home/cuckoo/.cuckoo/conf/kvm.conf; sed -i \"s/192.168.56.101/192.168.122.110/\" /home/cuckoo/.cuckoo/conf/kvm.conf'",
      "echo -e \"o\nn\np\n1\n\n\nw\" | sudo fdisk /dev/sdb; sudo /usr/sbin/mkfs.ext4 /dev/sdb1",
      "echo '/dev/sdb1    /var/lib/libvirt/images/  ext4 defaults 0 0'  | sudo tee -a /etc/fstab; sudo mount -a; sudo chmod 777 -R /var/lib/libvirt/images/",
      "echo '127.0.0.1    Sandbox' | sudo tee /etc/hosts",
      "echo 'auto eth1' | sudo tee -a /etc/network/interfaces",
      "echo 'iface eth1 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.14' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ifup eth1",
    ]
  }

  provisioner "file" {
    source = "./SCRIPTS/cuckoo-win10.sh"
    destination = "$HOME/cuckoo-win10.sh"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../packer/FILES/analyste.key ../ova/PACKER-cuckooVM/win10.qcow2 analyste@${self.ip_address}:/var/lib/libvirt/images/;  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../packer/FILES/analyste.key -t analyste@${self.ip_address} 'chmod +x $HOME/cuckoo-win10.sh; $HOME/cuckoo-win10.sh;'"
  }
}
