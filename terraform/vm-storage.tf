resource "esxi_guest" "dfirlab-storage" {
  count                 = 1
  guest_name            = "DFIRLab-${count.index + 1}-storage"
  notes                 = "Contact : me"
  disk_store            = var.datastore
  boot_disk_type        = "thin"
  memsize               = "1024"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"
  ovf_source            = "../packer/ova/template-Debian10.ova"

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

  # Commands executed on remote system through SSH connection
  provisioner "remote-exec" {
    inline = [
      "echo 'dfirlab-storage' | sudo tee /etc/hostname",
      "echo '127.0.0.1  dfirlab-storage' | sudo tee -a /etc/hosts",
      "echo -e \"o\nn\np\n1\n\n\nw\" | sudo fdisk /dev/sdb; sudo /usr/sbin/mkfs.ext4 /dev/sdb1",
      "sudo mkdir /media/evidences",
      "echo '/dev/sdb1    /media/evidences  ext4 defaults 0 0'  | sudo tee -a /etc/fstab; sudo mount -a",
      "sudo chmod -R 777 /media/evidences",
      "sudo apt update;  export DEBIAN_FRONTEND=noninteractive; sudo -E bash -c 'apt install -y samba samba-client'",
      "echo '[evidences]' | sudo tee -a /etc/samba/smb.conf",
      "echo '   comment = upload your evidences on this share' | sudo tee -a /etc/samba/smb.conf",
      "echo '   read only = no' | sudo tee -a /etc/samba/smb.conf",
      "echo '   path = /media/evidences' | sudo tee -a /etc/samba/smb.conf",
      "echo '   guest ok = yes' | sudo tee -a /etc/samba/smb.conf",
      "sudo /etc/init.d/samba-ad-dc restart",
      "echo 'auto eth1' | sudo tee -a /etc/network/interfaces",
      "echo 'iface eth1 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.15' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ifup eth1",
      "echo 'up route add -net 10.8.0.0/24 gw 10.1.1.254 dev eth1' | sudo tee -a /etc/network/interfaces",
      "sudo shutdown -r +1",
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
