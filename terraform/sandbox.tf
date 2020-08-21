
resource "esxi_virtual_disk" "vdisk2-sandbox" {
  count                 = 1
  virtual_disk_disk_store = "<esx_datastore>"
  virtual_disk_dir        = "PIN-${count.index + 1}-Sandbox"
  virtual_disk_size       = 40
  virtual_disk_type       = "thin"
}


resource "esxi_guest" "pin-sandbox" {
  count                 = 1
  guest_name            = "PIN-${count.index + 1}-Sandbox"
  notes                 = "Contact : me"
  disk_store            = "<esx_datastore>"
  boot_disk_type        = "thin"
  #boot_disk_size        = "100"
  memsize               = "4096"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"

  ovf_source = "../packer/ova/template-Debian10.ova"

  virtual_disks {
    virtual_disk_id = esxi_virtual_disk.vdisk2-sandbox[count.index].id
    slot            = "0:2"
  }

  network_interfaces {
    virtual_network = "<portgroup--terraform-deployment>"
    nic_type        = "e1000"
  }

  network_interfaces {
    virtual_network = "PIN-${count.index + 1}-vm"
    nic_type        = "e1000"
  }

  connection {
    host        = self.ip_address
    type        = "ssh"
    user        = "analyste"
    private_key = file("../packer/FILES/analyste.key")
    timeout     = "180s"
  }

  ## Command executed on remote VM through SSH connection
  provisioner "remote-exec" {
    inline = [
      "echo 'Sandbox' | sudo tee /etc/hostname",
      "sudo apt update; sudo apt install -y git-core cifs-utils",
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
      "sudo mkdir /media/evidences;",
      "sudo mount -t cifs -o username=root,password=,uid=1001,gid=1001 //10.1.1.15/evidences/ /media/evidences; sudo mkdir /media/evidences/cuckoo-analyses; sudo umount /media/evidences",
      "echo '//10.1.1.15/evidences/cuckoo-analyses /media/evidences cifs username=root,password=,uid=1001,gid=1001,iocharset=utf8,mfsymlinks 0 0' | sudo tee -a /etc/fstab; sudo mount -a",
      "sudo rm -rf /home/cuckoo/.cuckoo/storage",
      "sudo ln -s /media/evidences/ /home/cuckoo/.cuckoo/storage",
      "sudo mkdir /home/cuckoo/.cuckoo/storage/analyses /home/cuckoo/.cuckoo/storage/binaries/ /home/cuckoo/.cuckoo/storage/baseline",
      "sudo apt install -y ufw",
      "sudo sed -i '10iCOMMIT' /etc/ufw/before.rules",
      "sudo sed -i '10i-A PREROUTING -i virbr0 -d 192.168.122.1 -p tcp --dport 9200 -j DNAT --to-destination 10.1.1.11:9200' /etc/ufw/before.rules",
      "sudo sed -i '10i:PREROUTING ACCEPT [0:0]' /etc/ufw/before.rules",
      "sudo sed -i '10i*nat' /etc/ufw/before.rules",
      "sudo ufw allow in on eth0 to any port 22 proto tcp # SSH",
      "sudo ufw allow in on eth1 to any port 22 proto tcp # SSH",
      "sudo ufw allow in on eth0 to any port 8000 proto tcp # CUCKOO Web",
      "sudo ufw allow in on eth1 to any port 8000 proto tcp # CUCKOO Web",
      "sudo ufw allow in on virbr0 to any port 2042 proto tcp # Cuckoo result server",
      "sudo ufw allow in on virbr0 to any port 53 proto udp # DNS",
      "yes y | sudo ufw enable",
    ]
  }

  provisioner "file" {
    source = "./SCRIPTS/cuckoo-win10.sh"
    destination = "$HOME/cuckoo-win10.sh"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../packer/FILES/analyste.key ../packer/ova/PACKER-cuckooVM/win10/Win10.qcow2 analyste@${self.ip_address}:/var/lib/libvirt/images/;  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../packer/FILES/analyste.key -t analyste@${self.ip_address} 'chmod +x $HOME/cuckoo-win10.sh; $HOME/cuckoo-win10.sh;'"
  }
}
