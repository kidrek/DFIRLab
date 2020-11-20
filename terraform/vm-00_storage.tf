resource "esxi_guest" "dfirlab-storage" {
  count                 = 1
  guest_name            = "DFIRLab-${count.index + 1}-storage"
  notes                 = "Contact : me"
  disk_store            = var.datastore
  boot_disk_type        = "thin"
  memsize               = "512"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"
  ovf_source            = "../packer/ova/template-Debian10--storage.ova"

  # Evidences storage
  virtual_disks {
    virtual_disk_id = esxi_virtual_disk.dfirlab-storage-disk2[count.index].id
    slot            = "0:2"
  }

  # Network configuration
  network_interfaces {
    virtual_network = var.network-portgroup-deployment
    nic_type        = "e1000"
  }

  network_interfaces {
    virtual_network = "DFIRLab-${count.index + 1}-vm"
    nic_type        = "e1000"
  }

  # Connection used to apply some modifications on system
  connection {
    host        = self.ip_address
    type        = "ssh"
    user        = "analyste"
    private_key = file("../packer/FILES/analyste.key")
    timeout     = "180s"
  }

  ## Command executed on remote VM through SSH connection
  provisioner "file" {
    source = "./SCRIPTS/memory_autoanalyse.sh"
    destination = "/tmp/memory_autoanalyse.sh"
  }

  # Commands executed on remote system through SSH connection
  provisioner "remote-exec" {
    inline = [
      "echo 'dfirlab-storage' | sudo tee /etc/hostname",
      "echo '127.0.0.1  dfirlab-storage' | sudo tee -a /etc/hosts",
      "echo -e \"o\nn\np\n1\n\n\nw\" | sudo fdisk /dev/sdb; sudo /usr/sbin/mkfs.ext4 /dev/sdb1",
      "echo 'auto eth1' | sudo tee -a /etc/network/interfaces",
      "echo 'iface eth1 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.15' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ifup eth1",
      "echo 'up route add -net 10.8.0.0/24 gw 10.1.1.254 dev eth1' | sudo tee -a /etc/network/interfaces",
      "sudo mkdir /media/evidences",
      "echo '/dev/sdb1    /media/evidences  ext4 defaults 0 0'  | sudo tee -a /etc/fstab; sudo mount -a",
      "sudo mkdir /media/evidences/documentation",
      "sudo mkdir /media/evidences/MEMORY",
      "sudo mkdir /media/evidences/HDD",
      "sudo mv /tmp/memory_autoanalyse.sh /media/evidences/MEMORY/; chmod +x /media/evidences/MEMORY/memory_autoanalye.sh",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Evidence-of-Poster.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Find-Evil-Poster.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/SANS-DFIR.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Smartphone-Forensics-Poster.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/memory-forensics-cheatsheet.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/network-forensics-cheatsheet.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/sift-cheatsheet.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/windows-to-unix-cheatsheet.pdf",
      "sudo chmod -R 777 /media/evidences"
    ]
  }
}


resource "esxi_virtual_disk" "dfirlab-storage-disk2" {
  count                 = 1
  virtual_disk_disk_store = var.datastore
  virtual_disk_dir        = "DFIRLab-${count.index + 1}-STORAGE"
  virtual_disk_size       = var.extended-storage_sizes["vm--storage-disk2-evidences"]
  virtual_disk_type       = "thin"
}

