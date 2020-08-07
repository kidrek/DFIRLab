resource "esxi_virtual_disk" "vdisk2" {
  count                 = 1
  virtual_disk_disk_store = "datastore1"
  virtual_disk_dir        = "PIN-${count.index + 1}-STORAGE"
  virtual_disk_size       = 15
  virtual_disk_type       = "thin"
}

resource "esxi_guest" "pin-storage" {
  count                 = 1
  guest_name            = "PIN-${count.index + 1}-STORAGE"
  notes                 = "Contact : me"
  disk_store            = "datastore1"
  boot_disk_type        = "thin"
  #boot_disk_size        = "50"
  memsize               = "2048"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"

  virtual_disks {
    virtual_disk_id = esxi_virtual_disk.vdisk2[count.index].id
    slot            = "0:2"
  }

  ovf_source = "../ovf-template/debian.ova"

  network_interfaces {
    virtual_network = "Terraform-deployment"
    nic_type        = "e1000"
  }

  network_interfaces {
    virtual_network = "PIN-${count.index + 1}-vm"
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
      "echo 'storage' | sudo tee /etc/hostname",
      "echo '127.0.0.1  storage' | sudo tee -a /etc/hosts",
      "echo -e 'o\nn\np\n1\n\n\nw' | sudo fdisk /dev/sdb; sudo /usr/sbin/mkfs.ext4 /dev/sdb1",
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
      "echo 'auto ens37' | sudo tee -a /etc/network/interfaces",
      "echo 'iface ens37 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.15' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ifup ens37",
      "sudo reboot",
    ]
  }
}
